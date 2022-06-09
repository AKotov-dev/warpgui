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

      PingProcess.Executable := 'bash';  //sh или xterm
      PingProcess.Parameters.Add('-c');
      PingProcess.Parameters.Add(
        '[[ $(fping google.com) && $(ip -br a | grep CloudflareWARP) ]] && ' +
        'echo "yes" || echo "no"');

      PingProcess.Options := [poUsePipes, poWaitOnExit];

      //Если WARP зарегистрирован...
      if Registered then
      begin
        PingProcess.Execute;

        PingStr.LoadFromStream(PingProcess.Output);

        Synchronize(@ShowStatus);
      end;

      Sleep(1000);
    finally
      PingStr.Free;
      PingProcess.Free;
    end;
end;

procedure CheckPing.ShowStatus;
begin
  if Trim(PingStr[0]) = 'yes' then
  begin
    MainForm.ToolButton1.ImageIndex := 1;
    MainForm.Label1.Color := clGreen;
    MainForm.Label1.Caption := ConnectionIsEncrypted;
  end
  else
  begin
    MainForm.ToolButton1.ImageIndex := 0;
    MainForm.Label1.Color := clRed;
    MainForm.Label1.Caption := WaitingForConnection;
  end;
  MainForm.ToolButton1.Repaint;
  MainForm.Label1.Repaint;
end;

end.
