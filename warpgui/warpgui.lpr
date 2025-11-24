program warpgui;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  PingTRD,
  change_endpoint_trd,
  ResetTRD, ResetTRD_NEW;

  {$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.HintPause := 600;
  Application.HintHidePause := 3500;
  Application.HintHidePausePerChar := 0;
  Application.Title := 'warpgui-v2.5';
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
