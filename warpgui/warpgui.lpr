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
  ResetTRD;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.HintPause := 500;
  Application.HintHidePause := 3000;
  Application.HintHidePausePerChar := 0;
  Application.Title:='warpgui-v1.2';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
