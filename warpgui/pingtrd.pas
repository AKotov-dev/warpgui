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
      if Registered then
      begin
        //Статус ON/OFF
        PingProcess.Parameters.Add(
          '[[ $(ip -br a | grep CloudflareWARP) ]] && echo "yes" || echo "no"');
        PingProcess.Execute;
        PingStr.LoadFromStream(PingProcess.Output);
        Synchronize(@ShowStatus);

        //TX/RX
        PingProcess.Parameters.Delete(1);
        PingProcess.Parameters.Add('warp-cli warp-stats | awk ' +
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

//Вывод состояния (ON/OFF)
procedure CheckPing.ShowStatus;
begin
  with MainForm do
  begin
    if Trim(PingStr[0]) = 'yes' then
    begin
      ToolButton1.ImageIndex := 1;
      Label1.Color := clGreen;
      Label1.Caption := ConnectionIsEncrypted;
    end
    else
    begin
      ToolButton1.ImageIndex := 0;
      Label1.Color := clRed;
      Label1.Caption := WaitingForConnection;
    end;

    ToolButton1.Repaint;
    Label1.Repaint;
  end;
end;

//Вывод TX/RX (отправлено/принято)
procedure CheckPing.ShowUpDown;
begin
  if Trim(PingStr.Text) <> '' then
  begin
    //Разделяем два пришедших значения
    PingStr.Delimiter := ';';
    PingStr.StrictDelimiter := True;
    PingStr.DelimitedText := PingStr[0];

    MainForm.ToolButton1.Caption :=
      Concat('IN-', PingStr[1], '    ', 'OUT-', PingStr[0]);
  end;
end;

end.
