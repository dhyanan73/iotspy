unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.TabControl,
  FMX.StdCtrls, FMX.Gestures, FMX.Controls.Presentation, FMX.Layouts,
  FMX.Edit, System.Math.Vectors, FMX.Controls3D, FMX.Layers3D,
  FMX.ScrollBox, FMX.Memo, FMX.Objects, FrameRow, ClassDeviceConnect;

type
  TfrmMain = class(TForm)
    tbrHeader: TToolBar;
    lblToolBar: TLabel;
    tabMain: TTabControl;
    tabSearch: TTabItem;
    tabArchive: TTabItem;
    gesMain: TGestureManager;
    stbMain: TStyleBook;
    laySearchStr: TLayout;
    cmdSearch: TButton;
    txtSearch: TEdit;
    layResults: TLayout;
    panCommands: TPanel;
    cmdExit: TButton;
    grpSearchResultFilters: TGroupBox;
    layClearResults: TLayout;
    cmdClearResults: TButton;
    scrSearchResults: TScrollBox;
    layRows: TLayout;
    tabSettings: TTabItem;
    txtLog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure cmdExitClick(Sender: TObject);
    procedure scrSearchResultsResized(Sender: TObject);
    procedure cmdSearchClick(Sender: TObject);
  private
    function DeviceConnect(DeviceType: TIoTDeviceType; Host: string; Port: integer; Auth: string; out Msg: string): TfraRow;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  ClassDCNetwaveCam
  , System.Generics.Collections
  , FrameRowData
  , FrameNetwaveCam;

procedure TfrmMain.cmdExitClick(Sender: TObject);
begin

  Close;

end;

procedure TfrmMain.cmdSearchClick(Sender: TObject);
var
  Row: TfraRow;
  Msg: string;

begin

  Row := DeviceConnect(TIoTDeviceType.dtNetwaveCam, '88.1.116.214', 8069, 'admin:123456', Msg);

  if Assigned(Row) then
  begin
    Row.Name := 'Row' + IntToStr(layRows.Tag);
    Row.Parent := layRows;
    Row.Align := TAlignLayout.Top;
    layRows.Tag := layRows.Tag + 1;
    layRows.Height := Row.Height * layRows.Tag;
  end;

  txtLog.Lines.Add(Msg);

end;

function TfrmMain.DeviceConnect(DeviceType: TIoTDeviceType; Host: string; Port: integer; Auth: string; out Msg: string): TfraRow;
var
  Device: IDeviceConnect;
  OutPut: TDictionary<string, TObject>;
  Err: string;
  fraRowData: TfraRowData;

begin

  Result := TfraRow.Create(nil);
  OutPut := nil;
  fraRowData := nil;

  if DeviceType = TIoTDeviceType.dtNetwaveCam then
  begin
    Device := TDCNetwaveCam.Create;
    Device.Host := Host;
    Device.Auth := Auth;
    Device.Port := Port;
    OutPut := Device.Connect(Err);
    fraRowData := TfraNetwaveCam.Create(nil);
  end;

  if Assigned(OutPut) then
  begin
    fraRowData.DataEx := OutPut;
    fraRowData.Parent := Result.layRowData;
//    Result.layRowData.Controls.Add(fraRowData);
    Result.Host := Host;
    Result.Port := Port;
    Result.Auth := Auth;
    Msg := Host + ':' + IntToStr(Port) + ' connected with ' + Auth;
  end
  else
  begin
    FreeAndNil(Result);
    Msg := 'ERRORE: ' + Err;
  end;

end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin

  { This defines the default active tab at runtime }
  tabMain.ActiveTab := tabSearch;

end;

procedure TfrmMain.FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin

{$IFDEF ANDROID}
  case EventInfo.GestureID of
    sgiLeft:
    begin
      if TabControl1.ActiveTab <> TabControl1.Tabs[TabControl1.TabCount-1] then
        TabControl1.ActiveTab := TabControl1.Tabs[TabControl1.TabIndex+1];
      Handled := True;
    end;

    sgiRight:
    begin
      if TabControl1.ActiveTab <> TabControl1.Tabs[0] then
        TabControl1.ActiveTab := TabControl1.Tabs[TabControl1.TabIndex-1];
      Handled := True;
    end;
  end;
{$ENDIF}

end;

procedure TfrmMain.scrSearchResultsResized(Sender: TObject);
begin

  if layRows.Width < scrSearchResults.Width then
    layRows.Width := scrSearchResults.Width;

  if layRows.Height < scrSearchResults.Height then
    layRows.Height := scrSearchResults.Height;

end;

end.
