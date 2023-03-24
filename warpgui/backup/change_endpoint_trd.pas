unit change_endpoint_trd;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Forms, Controls, SysUtils, Process;

type
  ChangeEndpoint = class(TThread)
  private

    { Private declarations }
  protected

    procedure Execute; override;
    procedure StartChange;
    procedure StopChange;

  end;

implementation

uses Unit1;

{ TRD }

//Смена endpoint
procedure ChangeEndpoint.Execute;
var
  ChangeProcess: TProcess;
begin
  FreeOnTerminate := True; //Уничтожать по завершении
  try
    //Флаг запуска смены EndPoint/ResetWarp
    StartChangeEndpoint := True;

    Synchronize(@StartChange);

    ChangeProcess := TProcess.Create(nil);
    ChangeProcess.Executable := 'bash';
    ChangeProcess.Parameters.Add('-c');
    ChangeProcess.Options := [poWaitOnExit];

    //Замена EndPoint: замена, проба подключения (2 секунды ожидания)
    //warp-cli после одиночного connect сам пытается сделать несколько попыток подключения
    //если неудача или окончание спустя 2 сек флаг StartChangeEndpoint = False, поток PingTRD сбрасывает состояние Connecting
    ChangeProcess.Parameters.Add(
      'warp-cli --accept-tos clear-custom-endpoint; ' +
      'arr=("500" "4500" "2408"); rand=$[$RANDOM % ${#arr[@]}]; ' +
      'warp-cli --accept-tos set-custom-endpoint 162.159.19$((2 + $RANDOM %2)).$((1 + $RANDOM %10)):${arr[$rand]}; '
      + 'warp-cli --accept-tos connect; sleep 2'); { +
      'i=0; while [[ -z $(warp-cli --accept-tos status | grep Connected) ]]; do sleep 1; '
      + '((i++)); if [[ $i == 3 ]]; then warp-cli --accept-tos disconnect; break; fi; done');
                                             }
    ChangeProcess.Execute;

  finally
    Synchronize(@StopChange);
    StartChangeEndpoint := False;
    ChangeProcess.Free;
  end;
end;

//---Статус смены EndPoint---
procedure ChangeEndpoint.StartChange;
begin
  MainForm.Caption := EndPointChange + '...';
end;

procedure ChangeEndpoint.StopChange;
begin
  MainForm.Caption := Application.Title;
end;

end.
