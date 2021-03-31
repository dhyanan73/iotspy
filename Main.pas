unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.TabControl,
  FMX.StdCtrls, FMX.Gestures, FMX.Controls.Presentation, FMX.Layouts,
  FMX.Edit, System.Math.Vectors, FMX.Controls3D, FMX.Layers3D,
  FMX.ScrollBox, FMX.Memo, FMX.Objects, FrameRow, ClassDeviceConnect,
  FMX.ExtCtrls, FMX.Ani, System.Threading, FMX.ImgList, System.ImageList,
  FMX.ListBox, FMX.EditBox, FMX.NumberBox;

type

  TIoTBruteforceType = (btDictionary, btLCase, btLCaseDigits, btLUCase, btLUCaseDigits, btLCaseDigitsSpec,
                        btLUCaseDigitsSpec, btDicLCase, btDicLCaseDigits, btDicLUCase, btDicLUCaseDigits,
                        btDicLCaseDigitsSpec, btDicLUCaseDigitsSpec);
  TIoTImages = (imNone = -1, imIdleStatus = 0, imWorkingStatus = 1);
  TIoTLogType = (ltUnknown, ltInfo, ltAlert, ltError);
  TProcessStatus =  (
                      psUnknown,
                      psInitialization,
                      psStart,
                      psInProgress,
                      psWaitingForInput,
                      psPaused,
                      psEnded
                    );
  TProgressCallback = procedure(Total: Int64; Value: Int64) of object;
  TProcessStatusCallback = procedure(var ProcessStatus: TProcessStatus) of object;

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
    tabSettingsContent: TTabControl;
    tabSystem: TTabItem;
    tabBruteForce: TTabItem;
    grpAPIKey: TGroupBox;
    txtAPIKey: TEdit;
    panWait: TPanel;
    layWait: TLayout;
    prgWait: TProgressBar;
    imgWait: TImage;
    FloatAnimation1: TFloatAnimation;
    lblWait: TLabel;
    cmdStop: TButton;
    layStatus: TLayout;
    glyStatus: TGlyph;
    imlMain: TImageList;
    lblStatus: TLabel;
    grpBruteForceType: TGroupBox;
    cboBruteForceType: TComboBox;
    grpPassMinLen: TGroupBox;
    txtPassMinLen: TNumberBox;
    grpPassMaxLen: TGroupBox;
    txtPassMaxLen: TNumberBox;
    grpPassSpecialChars: TGroupBox;
    txtPassSpecialChars: TEdit;
    layDictionaries: TGridLayout;
    grpUserNameDic: TGroupBox;
    panUserNameDicCommands: TPanel;
    cmdClearUserNameDic: TButton;
    cmdAddUserNameDic: TButton;
    cmdLoadUserNameDic: TButton;
    txtUserNameDic: TMemo;
    grpPasswordDic: TGroupBox;
    panPasswordDicCommands: TPanel;
    cmdClearPasswordDic: TButton;
    cmdAddPasswordDic: TButton;
    cmdLoadPasswordDic: TButton;
    txtPasswordDic: TMemo;
    lblUserNameDicCount: TLabel;
    lblPasswordDicCount: TLabel;
    layBruteforcePrg: TLayout;
    cmdStopBruteForce: TButton;
    prgBruteForce: TProgressBar;
    dlgOpenFile: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure cmdExitClick(Sender: TObject);
    procedure scrSearchResultsResized(Sender: TObject);
    procedure cmdSearchClick(Sender: TObject);
    procedure ProgressCallback(Total: Int64; Value: Int64);
    procedure ProcessStatusCallback(var ProcessStatus: TProcessStatus);
    procedure cmdStopClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure layDictionariesResized(Sender: TObject);
    procedure tabMainChange(Sender: TObject);
    procedure txtPassMinLenExit(Sender: TObject);
    procedure txtPassMaxLenExit(Sender: TObject);
    procedure tabSettingsContentChange(Sender: TObject);
    procedure cmdClearUserNameDicClick(Sender: TObject);
    procedure cmdClearPasswordDicClick(Sender: TObject);
    procedure cmdLoadUserNameDicClick(Sender: TObject);
    procedure cmdLoadPasswordDicClick(Sender: TObject);
    procedure cmdAddPasswordDicClick(Sender: TObject);
    procedure cmdAddUserNameDicClick(Sender: TObject);
  private
    CurrTask: ITask;
    function DeviceConnect(DeviceType: TIoTDeviceType; Host: string; Port: integer; Auth: string; out Msg: string): TfraRow;
    procedure TaskFinished;
    procedure SaveSettings;
    procedure LoadSettings;
    procedure ValidatePwdLenLimit(Source: TNumberBox = nil);
    procedure SaveUserNameDic;
    procedure SavePasswordDic;
    function OpenFile: string;
  protected
  public
    procedure Log(const Msg: string; LogType: TIoTLogType = TIoTLogType.ltInfo);
    procedure CancelTask(Task: ITask);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  ClassDCNetwaveCam
  , System.Generics.Collections
  , FrameRowData
  , FrameNetwaveCam
  , ShodanAPI
  , SettingsPersistence
  , Constants;

procedure ClearStringDuplicateItems(Lines: TStrings; CaseSensitive: boolean = true);
var
  i, x: Int64;
  Done: boolean;

begin

  i := 0;
  Done := false;

  while not Done do
  begin
    if i < Lines.Count then
    begin
      for x := Lines.Count - 1 downto i + 1  do
        if CaseSensitive then
        begin
          if Lines[x] = Lines[i] then
            Lines.Delete(x);
        end
        else
          if UpperCase(Lines[x]) = UpperCase(Lines[i]) then
            Lines.Delete(x);
      i := i + 1;
    end
    else
      Done := true;
  end;

end;

procedure TfrmMain.CancelTask(Task: ITask);
begin

  if Assigned(Task) then
  begin
    Task.Cancel;
    repeat
      if not Task.Wait(1000) then
        CheckSynchronize;
    until Task = nil;
  end;

end;

procedure TfrmMain.cmdAddPasswordDicClick(Sender: TObject);
var
  FileName: string;
  StringList: TStringList;

begin

  cmdAddPasswordDic.Enabled := false;

  try
    FileName := OpenFile();
    if FileExists(FileName) and (FileName <> '') then
    begin
      txtPasswordDic.Lines.BeginUpdate;
      try
        StringList := TStringList.Create;
        try
          StringList.LoadFromFile(FileName);
          txtPasswordDic.Lines.AddStrings(StringList);
        finally
          StringList.Free;
        end;
        ClearStringDuplicateItems(txtPasswordDic.Lines);
        SavePasswordDic;
      finally
        txtPasswordDic.Lines.EndUpdate;
      end;
      lblPasswordDicCount.Text := IntTostr(txtPasswordDic.Lines.Count) + ' items';
    end;
  finally
    cmdAddPasswordDic.Enabled := true;
  end;

end;

procedure TfrmMain.cmdAddUserNameDicClick(Sender: TObject);
var
  FileName: string;
  StringList: TStringList;

begin

  cmdAddUserNameDic.Enabled := false;

  try
    FileName := OpenFile();
    if FileExists(FileName) and (FileName <> '') then
    begin
      txtUserNameDic.Lines.BeginUpdate;
      try
        StringList := TStringList.Create;
        try
          StringList.LoadFromFile(FileName);
          txtUserNameDic.Lines.AddStrings(StringList);
        finally
          StringList.Free;
        end;
        ClearStringDuplicateItems(txtUserNameDic.Lines, false);
        SaveUserNameDic;
      finally
        txtUserNameDic.Lines.EndUpdate;
      end;
      lblUserNameDicCount.Text := IntTostr(txtUserNameDic.Lines.Count) + ' items';
    end;
  finally
    cmdAddUserNameDic.Enabled := true;
  end;

end;

procedure TfrmMain.cmdClearPasswordDicClick(Sender: TObject);
begin

  cmdClearPasswordDic.Enabled := false;

  try
    txtPasswordDic.Lines.BeginUpdate;
    try
      txtPasswordDic.Lines.Clear;
      SavePasswordDic;
    finally
      txtPasswordDic.Lines.EndUpdate;
    end;
    lblPasswordDicCount.Text := IntTostr(txtPasswordDic.Lines.Count) + ' items';
  finally
    cmdClearPasswordDic.Enabled := true;
  end;

end;

procedure TfrmMain.cmdClearUserNameDicClick(Sender: TObject);
begin

  cmdClearUserNameDic.Enabled := false;

  try
    txtUserNameDic.Lines.BeginUpdate;
    try
      txtUserNameDic.Lines.Clear;
      SaveUserNameDic;
    finally
      txtUserNameDic.Lines.EndUpdate;
    end;
    lblUserNameDicCount.Text := IntTostr(txtUserNameDic.Lines.Count) + ' items';
  finally
    cmdClearUserNameDic.Enabled := true;
  end;

end;

procedure TfrmMain.cmdExitClick(Sender: TObject);
begin

  cmdExit.Enabled := false;
  Application.ProcessMessages;
  Close;

end;

procedure TfrmMain.cmdLoadPasswordDicClick(Sender: TObject);
var
  FileName: string;

begin

  cmdLoadPasswordDic.Enabled := false;

  try
    if Assigned(Sender) then
      FileName := OpenFile()
    else
      FileName := GetAppDataFldPath + IOT_PASSWORD_DICT_FILE_NAME;
    if FileExists(FileName) and (FileName <> '') then
    begin
      txtPasswordDic.Lines.BeginUpdate;
      try
        txtPasswordDic.Lines.LoadFromFile(FileName);
        ClearStringDuplicateItems(txtPasswordDic.Lines);
        if Assigned(Sender) then
          SavePasswordDic;
      finally
        txtPasswordDic.Lines.EndUpdate;
      end;
      lblPasswordDicCount.Text := IntTostr(txtPasswordDic.Lines.Count) + ' items';
    end;
  finally
    cmdLoadPasswordDic.Enabled := true;
  end;

end;

procedure TfrmMain.cmdLoadUserNameDicClick(Sender: TObject);
var
  FileName: string;

begin

  cmdLoadUserNameDic.Enabled := false;

  try
    if Assigned(Sender) then
      FileName := OpenFile()
    else
      FileName := GetAppDataFldPath + IOT_USER_NAME_DICT_FILE_NAME;
    if FileExists(FileName) and (FileName <> '') then
    begin
      txtUserNameDic.Lines.BeginUpdate;
      try
        txtUserNameDic.Lines.LoadFromFile(FileName);
        ClearStringDuplicateItems(txtUserNameDic.Lines, false);
        if Assigned(Sender) then
          SaveUserNameDic;
      finally
        txtUserNameDic.Lines.EndUpdate;
      end;
      lblUserNameDicCount.Text := IntTostr(txtUserNameDic.Lines.Count) + ' items';
    end;
  finally
    cmdLoadUserNameDic.Enabled := true;
  end;

end;

procedure TfrmMain.cmdSearchClick(Sender: TObject);
var
  Row: TfraRow;
  Msg, Query, APIKey: string;
  QueryResult: TShoResponse;
  ProcessStatus: TProcessStatus;

begin

  try
    Application.ProcessMessages;
    cmdSearch.Enabled := false;
    try
      Query := Trim(txtSearch.Text);

      if Query = '' then
      begin
        Log('Invalid search query.', ltError);
        txtSearch.SetFocus;
        Exit;
      end;

      APIKey := Trim(txtAPIKey.Text);

      if APIKey = '' then
      begin
        Log('Invalid API key.', ltError);
        tabMain.TabIndex := 2;
        tabSettingsContent.TabIndex := 0;
        txtAPIKey.SetFocus;
        Exit;
      end;

      Log('Searching...');

      prgWait.Max := 0;
      prgWait.Value := 0;
      prgWait.Visible := false;
      panWait.Visible := true;
      txtLog.BringToFront;
      Application.ProcessMessages;

      try
        QueryResult := nil;
        ProcessStatus := TProcessStatus.psStart;
        ProcessStatusCallback(ProcessStatus);
        CurrTask := TTask.Create (
                        procedure
                        begin
                          GetQueryResults (
                                            QueryResult
                                            , APIKey
                                            , Query
                                            , Msg
                                            , 0
                                            , 5
                                            , ProgressCallback
                                            , TaskFinished
                                          );
                        end
                      ).Start;
        while Assigned(CurrTask) and (not (CurrTask.Status in [TTaskStatus.Completed, TTaskStatus.Canceled, TTaskStatus.Exception])) do
          Application.ProcessMessages;
        if tabMain.Enabled then
        begin
          if Assigned(QueryResult) then
          begin
            try
              Log(Format('%d matches found', [QueryResult.total]));
              Log(Format('Start loading %d matches...', [Length(QueryResult.matches)]));
            finally
              QueryResult.Free;
            end;
          end
          else
            Log(Msg, ltError);
        end;
      finally
        prgWait.Visible := false;
        panWait.Visible := false;
        Application.ProcessMessages;
      end;
    finally
      cmdSearch.Enabled := true;
    end;
  except
    on E: Exception do
      Log(E.Message, ltError);
  end;







{
  Row := DeviceConnect(TIoTDeviceType.dtNetwaveCam, '88.1.116.214', 8069, 'admin:123456', Msg);

  if Assigned(Row) then
  begin
    Row.Name := 'Row' + IntToStr(layRows.Tag);
    Row.Parent := layRows;
    Row.Align := TAlignLayout.Top;
    layRows.Tag := layRows.Tag + 1;
    layRows.Height := Row.Height * layRows.Tag;
  end;

  Log(Msg);
}

end;

procedure TfrmMain.cmdStopClick(Sender: TObject);
begin

//  StopProcess := true;
  try
    CancelTask(CurrTask);
  except
    on E: Exception do
      Log('Process ended by user.');
  end;

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
    Result.TagObject := fraRowData;
    Result.Host := Host;
    Result.Port := Port;
    Result.Auth := Auth;
    Msg := Host + ':' + IntToStr(Port) + ' connected with ' + Auth;
  end
  else
  begin
    if Assigned(fraRowData) then
      fraRowData.Free;
    FreeAndNil(Result);
  end;

end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  tabMain.Enabled := false;
  cmdExit.Enabled := false;
  Application.ProcessMessages;
  SaveSettings;

  if Assigned(CurrTask) then
  begin
    try
      CancelTask(CurrTask);
    except
      on E: Exception do
      begin
        Log('Closing...');
        glyStatus.ImageIndex := integer(TIoTImages.imWorkingStatus);
        lblStatus.Text := 'Closing';
      end;
    end;
  end;

  Action := TCloseAction.caFree;

end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
{
  if Assigned(CurrTask) then
  begin
    CurrTask.Cancel;
    while not (CurrTask.Status in [TTaskStatus.Completed, TTaskStatus.Canceled, TTaskStatus.Exception]) do
      Application.ProcessMessages;
    Application.ProcessMessages;
  end;
}

  CanClose := true;

end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin

  CurrTask := nil;
  tabMain.ActiveTab := tabSearch;
  tabSettingsContent.ActiveTab := tabSystem;

end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin

  CancelTask(CurrTask);

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

procedure TfrmMain.FormShow(Sender: TObject);
begin

  LoadSettings;

end;

procedure TfrmMain.layDictionariesResized(Sender: TObject);
begin

  layDictionaries.ItemHeight := layDictionaries.Height;
  layDictionaries.ItemWidth := Trunc(layDictionaries.ItemWidth / 2) - 2;
  layDictionaries.Repaint;
  Application.ProcessMessages;

end;

procedure TfrmMain.LoadSettings;
begin

  tabMain.ActiveTab := tabSearch;
  tabMain.Enabled := false;
  prgWait.Visible := false;
  panWait.Visible := true;
  txtLog.BringToFront;
  Log('Loading settings...');
  glyStatus.ImageIndex := integer(TIoTImages.imWorkingStatus);
  lblStatus.Text := 'Loading settings';
  Application.ProcessMessages;

  try
    txtSearch.Text := ReadSetting(IOT_SET_SECT_SYSTEM, IOT_SET_VAL_LAST_QUERY, '');
    txtAPIKey.Text := ReadSetting(IOT_SET_SECT_SYSTEM, IOT_SET_API_KEY, '');
    cboBruteForceType.ItemIndex := ReadSetting(IOT_SET_SECT_BRUTE_FORCE, IOT_SET_VAL_BRUTE_FORCE_TYPE, 0);
    txtPassMinLen.Text := ReadSetting(IOT_SET_SECT_BRUTE_FORCE, IOT_SET_VAL_BRUTE_FORCE_MIN_LEN, 4);
    txtPassMaxLen.Text := ReadSetting(IOT_SET_SECT_BRUTE_FORCE, IOT_SET_VAL_BRUTE_FORCE_MAX_LEN, 8);
    ValidatePwdLenLimit(txtPassMaxLen);
    txtPassSpecialChars.Text := ReadSetting(IOT_SET_SECT_BRUTE_FORCE, IOT_SET_VAL_BRUTE_FORCE_SPECIAL_CHARS, '!"#$%&''()*+,-./;<=>?@[\]^_|');
    cmdLoadUserNameDicClick(nil);
    cmdLoadPasswordDicClick(nil);
  finally
    Log('Settings loaded');
    if Assigned(CurrTask) then
      lblStatus.Text := 'Working'
    else
    begin
      glyStatus.ImageIndex := integer(TIoTImages.imIdleStatus);
      lblStatus.Text := 'Idle';
    end;
    tabMain.Enabled := true;
    panWait.Visible := false;
  end;

end;

procedure TfrmMain.Log(const Msg: string; LogType: TIoTLogType);
var
  Log: string;

begin

  if Trim(Msg) <> '' then
  begin
    Log := Format('[%s] ', [DateTimeToStr(Now)]);
    case LogType of
      TIoTLogType.ltAlert : Log := Log + '(ALERT) ';
      TIoTLogType.ltError : Log := Log + '(ERROR) ';
    end;
    Log := Log + Trim(Msg);
    txtLog.Lines.Add(Log);
    txtLog.GoToTextEnd;
    Application.ProcessMessages;
  end;

end;

function TfrmMain.OpenFile: string;
begin

  Result := '';

  if dlgOpenFile.Execute then
    Result := dlgOpenFile.FileName;

end;

procedure TfrmMain.ProcessStatusCallback(var ProcessStatus: TProcessStatus);
begin
{
  if StopProcess then
  begin
    try
      ProcessStatus := TProcessStatus.psEnded;
      raise Exception.Create('Process ended by user.');
    finally
      StopProcess := false;
    end;
  end;
}

  if ProcessStatus = TProcessStatus.psEnded then
  begin
    CurrTask := nil;
    glyStatus.ImageIndex := integer(TIoTImages.imIdleStatus);
    lblStatus.Text := 'Idle';
  end;

  if ProcessStatus = TProcessStatus.psStart then
  begin
    glyStatus.ImageIndex := integer(TIoTImages.imWorkingStatus);
    lblStatus.Text := 'Working';
  end;

end;

procedure TfrmMain.ProgressCallback(Total, Value: Int64);
begin

  if Assigned(CurrTask) then
    CurrTask.CheckCanceled;

  if Total > 0 then
  begin
    prgWait.Visible := true;
    prgWait.Max := Total;
    prgWait.Value := Value;
    Application.ProcessMessages;
  end;

end;

procedure TfrmMain.SavePasswordDic;
begin

  txtPasswordDic.Lines.SaveToFile(GetAppDataFldPath + IOT_PASSWORD_DICT_FILE_NAME);

end;

procedure TfrmMain.SaveSettings;
begin

  Log('Saving settings...');
  glyStatus.ImageIndex := integer(TIoTImages.imWorkingStatus);
  lblStatus.Text := 'Saving settings';

  try
    WriteSetting(IOT_SET_SECT_SYSTEM, IOT_SET_VAL_LAST_QUERY, Trim(txtSearch.Text));
    WriteSetting(IOT_SET_SECT_SYSTEM, IOT_SET_API_KEY, Trim(txtAPIKey.Text));
    WriteSetting(IOT_SET_SECT_BRUTE_FORCE, IOT_SET_VAL_BRUTE_FORCE_TYPE, cboBruteForceType.ItemIndex);
    ValidatePwdLenLimit(txtPassMaxLen);
    WriteSetting(IOT_SET_SECT_BRUTE_FORCE, IOT_SET_VAL_BRUTE_FORCE_MIN_LEN, txtPassMinLen.Text);
    WriteSetting(IOT_SET_SECT_BRUTE_FORCE, IOT_SET_VAL_BRUTE_FORCE_MAX_LEN, txtPassMaxLen.Text);
    WriteSetting(IOT_SET_SECT_BRUTE_FORCE, IOT_SET_VAL_BRUTE_FORCE_SPECIAL_CHARS, txtPassSpecialChars.Text);
  finally
    Log('Settings saved');
    if Assigned(CurrTask) then
      lblStatus.Text := 'Working'
    else
    begin
      glyStatus.ImageIndex := integer(TIoTImages.imIdleStatus);
      lblStatus.Text := 'Idle';
    end;
  end;

end;

procedure TfrmMain.SaveUserNameDic;
begin

  txtUserNameDic.Lines.SaveToFile(GetAppDataFldPath + IOT_USER_NAME_DICT_FILE_NAME);

end;

procedure TfrmMain.scrSearchResultsResized(Sender: TObject);
begin
{
  if layRows.Width < scrSearchResults.Width then
    layRows.Width := scrSearchResults.Width;

  if layRows.Height < scrSearchResults.Height then
    layRows.Height := scrSearchResults.Height;
}
end;

procedure TfrmMain.tabMainChange(Sender: TObject);
begin

  layDictionariesResized(nil);

  if tabMain.TabIndex = 0 then
    txtSearch.SetFocus;

end;

procedure TfrmMain.tabSettingsContentChange(Sender: TObject);
begin

  if tabSettingsContent.TabIndex = 0 then
    txtAPIKey.SetFocus;

  if tabSettingsContent.TabIndex = 1 then
    cboBruteForceType.SetFocus;

end;

procedure TfrmMain.TaskFinished;
var
  Status: TProcessStatus;

begin

    Status := TProcessStatus.psEnded;
    ProcessStatusCallback(Status);

end;

procedure TfrmMain.txtPassMaxLenExit(Sender: TObject);
begin

  ValidatePwdLenLimit(txtPassMaxLen);

end;

procedure TfrmMain.txtPassMinLenExit(Sender: TObject);
begin

  ValidatePwdLenLimit(txtPassMinLen);

end;

procedure TfrmMain.ValidatePwdLenLimit(Source: TNumberBox = nil);
begin

  if Assigned(Source) then
  begin
    if Source.Equals(txtPassMinLen) then
    begin
      if StrToInt(txtPassMaxLen.Text) < StrToInt(txtPassMinLen.Text) then
        txtPassMaxLen.Text := txtPassMinLen.Text;
    end;
    if Source.Equals(txtPassMaxLen) then
    begin
      if StrToInt(txtPassMinLen.Text) > StrToInt(txtPassMaxLen.Text) then
        txtPassMinLen.Text := txtPassMaxLen.Text;
    end;
  end;


end;

end.
