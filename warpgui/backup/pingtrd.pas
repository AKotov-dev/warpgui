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

      //Если WARP зарегистрирован...
    //  if Registered then
    //  begin
        //Статус ON/OFF
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
     // end;

      Sleep(1000);
    finally
      PingStr.Free;
      PingProcess.Free;
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

      //Освобождение сети, если WARP заблокирован снаружи и нет флага смены EndPoint
      //или нажат Запуск на плохом endpoint
      if not StartChangeEndpoint then
        StartProcess('[[ $(warp-cli --accept-tos status | grep Connect) ]] && warp-cli --accept-tos disconnect');
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
