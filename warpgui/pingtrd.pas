unit PingTRD;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, Controls, SysUtils, Process, Graphics;

type
  CheckPing = class(TThread)
  private

    { Private declarations }
  protected
  var
    PingStr: TStringList;

    procedure Execute; override;
    procedure ShowRegistration;
    procedure ShowStatus;
    procedure ShowUpDown;

  end;

implementation

uses unit1;

{ TRD }

//Контроль статуса
procedure CheckPing.Execute;
var
  PingProcess: TProcess;
begin
  FreeOnTerminate := True; //Уничтожать по завершении

  while not Terminated do
    try
      PingStr := TStringList.Create;
      PingProcess := TProcess.Create(nil);

      PingProcess.Executable := 'bash';
      PingProcess.Options := [poUsePipes, poWaitOnExit];
      PingProcess.Parameters.Add('-c');

      //Проверка длительного зависания на плохом EndPoint (уходим от блокировки, ожидание 2 сек)
     { PingProcess.Parameters.Add(
        'i=0; while [[ $(warp-cli --accept-tos status | grep Connecting) ]]; do sleep 1; '
        + '((i++)); if [[ $i == 3 ]]; then warp-cli --accept-tos disconnect; break; fi; done');
      }
      PingProcess.Parameters.Add('sleep 0');

      PingProcess.Execute;

      //Регистрация (yes/no?)
      PingProcess.Parameters.Delete(1);
      PingProcess.Parameters.Add(
        'if [[ $(warp-cli --accept-tos status | grep -iE "registration|network|failed|error") ]]; '
        + 'then echo "no"; else echo "yes"; fi');

      PingProcess.Execute;
      PingStr.LoadFromStream(PingProcess.Output);
      Synchronize(@ShowRegistration);

      //Если регистрация пройдена - выводим всё остальное
      if PingStr[0] = 'yes' then
      begin
        //Статус ON/OFF
        PingProcess.Parameters.Delete(1);
        PingProcess.Parameters.Add(
          '[[ $(ip -br a | grep CloudflareWARP) ]] && echo "yes" || echo "no"');
        PingProcess.Execute;
        PingStr.LoadFromStream(PingProcess.Output);
        Synchronize(@ShowStatus);

        //Статус IN/OUT
        PingProcess.Parameters.Delete(1);
        PingProcess.Parameters.Add('warp-cli --accept-tos warp-stats | awk ' +
          '''' + 'NR == 3{print$2$4}' + '''');
        PingProcess.Execute;
        PingStr.LoadFromStream(PingProcess.Output);
        Synchronize(@ShowUpDown);
      end;

      Sleep(1000);
    finally
      PingStr.Free;
      PingProcess.Free;
    end;
end;

//Состояние Регистрации
procedure CheckPing.ShowRegistration;
begin
  with MainForm do
  begin
    if Trim(PingStr[0]) = 'no' then
    begin
      StartBtn.ImageIndex := 0;
      StatusLabel.Color := clGray;
      StatusLabel.Caption := WaitRegistration;
    end;
  end;
end;

//Вывод состояния (ON/OFF)
procedure CheckPing.ShowStatus;
begin
  with MainForm do
  begin
    if Trim(PingStr[0]) = 'yes' then
    begin
      StartBtn.ImageIndex := 1;
      StatusLabel.Color := clGreen;
      StatusLabel.Caption := ConnectionIsEncrypted;
    end
    else
    begin
      StartBtn.ImageIndex := 0;
      StatusLabel.Color := clRed;
      StatusLabel.Caption := WaitingForConnection;
    end;

    StartBtn.Repaint;
    StatusLabel.Repaint;
  end;
end;

//Вывод IN/OUT (принято/отправлено)
procedure CheckPing.ShowUpDown;
begin
  if Trim(PingStr.Text) <> '' then
  begin
    //Разделяем два пришедших значения
    PingStr.Delimiter := ';';
    PingStr.StrictDelimiter := True;
    PingStr.DelimitedText := PingStr[0];

    MainForm.StartBtn.Caption :=
      Concat('IN-', PingStr[1], '    ', 'OUT-', PingStr[0]);
  end;
end;

end.
