program IotSpy;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {frmMain},
  FrameRow in 'FrameRow.pas' {fraRow: TFrame},
  FrameRowData in 'FrameRowData.pas' {fraRowData: TFrame},
  FrameNetwaveCam in 'Devices\FrameNetwaveCam.pas' {fraNetwaveCam: TFrame},
  ClassDeviceConnect in 'ClassDeviceConnect.pas',
  ClassDCNetwaveCam in 'Devices\ClassDCNetwaveCam.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
