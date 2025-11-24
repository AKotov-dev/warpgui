unit ResetTRD_NEW;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Forms, Controls, SysUtils, Process;

type
  ResetWarpNEW = class(TThread)
  private

    { Private declarations }
  protected

    procedure Execute; override;
    procedure StartReset;
    procedure StopReset;

  end;

implementation

uses Unit1;

  { TRD }

//Сброс для нового протокола
procedure ResetWarpNEW.Execute;
var
  ResetProcess: TProcess;
begin
  FreeOnTerminate := True; //Уничтожать по завершении
  try
    //Флаг запуска смены EndPoint/ResetWarp
    StartChangeEndpoint := True;

    Synchronize(@StartReset);

    ResetProcess := TProcess.Create(nil);
    ResetProcess.Executable := 'bash';
    ResetProcess.Parameters.Add('-c');
    ResetProcess.Options := [poWaitOnExit];

    //Сброс настроек WARP + masque flag
    ResetProcess.Parameters.Add(
      'warp-cli --accept-tos disconnect; warp-cli --accept-tos settings reset; ' +
      'warp-cli --accept-tos registration new; warp-cli --accept-tos tunnel protocol set MASQUE');

    ResetProcess.Execute;

  finally
    Synchronize(@StopReset);
    StartChangeEndpoint := False;
    ResetProcess.Free;
  end;
end;

//---Статус сброса настроек WARP---
procedure ResetWarpNEW.StartReset;
begin
  MainForm.Caption := ResetWarpMsg + '...';
end;

procedure ResetWarpNEW.StopReset;
begin
  with MainForm do
  begin
    // WarpRegister;
    Caption := Application.Title;
  end;
end;

end.
