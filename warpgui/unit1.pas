unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Process, LCLTranslator, DefaultTranslator, IniPropStorage;

type

  { TMainForm }

  TMainForm = class(TForm)
    ImageList1: TImageList;
    IniPropStorage1: TIniPropStorage;
    StatusLabel: TLabel;
    ToolBar1: TToolBar;
    StartBtn: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure WarpRegister;
    procedure StartProcess(command: string);
    procedure StartBtnClick(Sender: TObject);

  private

  public

  end;

resourcestring
  ConnectionIsEncrypted = 'connection is encrypted';
  WaitingForConnection = 'waiting for connection...';
  ConnectionAttempt = 'connection attempt...';
  Disconnection = 'disconnection...';
  WarpSVCStatus = 'warp-svc.service is not running!' + sLineBreak +
    sLineBreak + 'systemctl enable warp-svc.service' + sLineBreak +
    'systemctl restart warp-svc.service';
  EndPointChange = 'replacing endpoint';
  ResetWarpMsg = 'reset settings';
  UpdateWarpMsg = 'warp update';
  WaitRegistration = 'registration attempt...';

var
  MainForm: TMainForm;
  StartChangeEndpoint, UpdateKeyPress: boolean;
  //Флаг окончания смены EndPoint [F12] и кнопки Update [F2]

implementation

uses PingTRD, Update_TRD, Change_Endpoint_TRD, ResetTRD;

  {$R *.lfm}

  { TMainForm }

//1. Проверка статуса warp-svc.service (active/inactive)
//2. Регистрация warp-cli register
procedure TMainForm.WarpRegister;
var
  S: TStringList;
  ExProcess: TProcess;
begin
  S := TStringList.Create;
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := '/bin/bash';
    ExProcess.Parameters.Add('-c');
    ExProcess.Options := [poUsePipes];

    //1. Проверка статуса warp-svc.service
    ExProcess.Parameters.Add('systemctl is-active warp-svc.service');
    ExProcess.Execute;
    S.LoadFromStream(ExProcess.Output);

    if (S[0] <> 'active') and (FileExists('/usr/bin/warp-svc')) then
    begin
      MessageDlg(WarpSVCStatus, mtWarning, [mbOK], 0);
      Application.Terminate;
    end;

    //2. Проверка/Запуск регистрации
    ExProcess.Parameters.Delete(1);
    ExProcess.Parameters.Add(
      '[[ $(warp-cli --accept-tos status | grep -iE "registration|failed|error") ]] && warp-cli --accept-tos registration new');

    ExProcess.Execute;

  finally
    S.Free;
    ExProcess.Free;
  end;
end;

//Общая процедура запуска команд (асинхронная)
procedure TMainForm.StartProcess(command: string);
var
  ExProcess: TProcess;
begin
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := '/bin/bash';
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add(command);
    //ExProcess.Options:=[poWaitOnExit];

    ExProcess.Execute;
  finally
    ExProcess.Free;
  end;
end;

//Запуск/Останов
procedure TMainForm.StartBtnClick(Sender: TObject);
begin
  Application.ProcessMessages;

  if StartBtn.ImageIndex = 0 then
  begin
    StatusLabel.Caption := ConnectionAttempt;

    //Проверка длительного зависания на плохом EndPoint (уходим от блокировки, ожидание 3 сек)
    StartProcess('warp-cli --accept-tos connect; ' +
      'i=0; while [[ -z $(ip -br a | grep CloudflareWARP) ]]; do sleep 1; ' +
      '((i++)); if [[ $i == 3 ]]; then warp-cli --accept-tos disconnect; break; fi; done');
  end
  else
  begin
    StatusLabel.Caption := Disconnection;
    StartProcess('warp-cli --accept-tos disconnect');
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  FCheckPingThread, FUpdateThread: TThread;
begin
  MainForm.Caption := Application.Title;

  //Инициализация флага одиночного нажатия F11/F12
  StartChangeEndpoint := False;

  //Проверка/Регистрация WARP
  WarpRegister;

  IniPropStorage1.IniFileName := GetUserDir + '.config/warpgui.ini';

  //Поток проверки пинга
  FCheckPingThread := CheckPing.Create(False);
  FCheckPingThread.Priority := tpNormal;

  //Поток проверки обновлений WARP
  FUpdateThread := CheckUpdate.Create(False);
  FUpdateThread.Priority := tpNormal;
end;

//Опрос клавы
procedure TMainForm.FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
var
  FChangeEndpointThread, FResetWarpThread, FUpdateThread: TThread;
begin
  //Установка/Обновление cloudflare-warp [F2]
  if (Key = $71) and (StartChangeEndpoint = False) then
  begin
    //Поток проверки обновлений WARP
    UpdateKeyPress := True;
    FUpdateThread := CheckUpdate.Create(False);
    FUpdateThread.Priority := tpNormal;
  end;

  //Сброс настроек WARP [F11]
  if (Key = $7A) and (StartChangeEndpoint = False) then
  begin
    //Поток сброса настроек WARP
    FResetWarpThread := ResetWarp.Create(False);
    FResetWarpThread.Priority := tpNormal;
  end;

  //Замена EndPoint [F12]
  if (Key = $7B) and (StartChangeEndpoint = False) then
  begin
    //Поток проверки обновлений WARP
    FChangeEndpointThread := ChangeEndpoint.Create(False);
    FChangeEndpointThread.Priority := tpNormal;
  end;
end;

end.
