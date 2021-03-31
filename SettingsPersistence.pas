unit SettingsPersistence;

interface

  function GetAppDataFldPath(SubFolder: string = ''): string;
  function ReadSetting(Section, Name: string; Default: variant): variant;
  procedure WriteSetting(Section, Name: string; Value: variant);
  procedure DeleteSetting(Section, Name: string);

//  function IncludeTrailingSlash(const S: string): string;
//  function GetAppTempFldPath: string;
//  function GetAppLanguagesFldPath: string;
//  procedure StrToFile(const FileName, SourceString: string);
//  function qgURLDownloadToFile(LocalFilePathName, URL: string; out Err: string): boolean;
//  function JSONObjToStr(JSON: TJSONObject): string;

implementation

uses
  System.SysUtils
  , System.IOUtils
  , System.Variants
  , System.IniFiles
  , Constants;

function GetAppDataFldPath(SubFolder: string = ''): string;
begin

  Result := TPath.GetHomePath;

  if Result <> '' then
  begin
    Result := Result + TPath.DirectorySeparatorChar + IOT_APP_INTERNAL_NAME;
    SubFolder := Trim(SubFolder);
    if SubFolder <> '' then
    begin
      if not System.SysUtils.IsPathDelimiter(SubFolder, 1) then
        SubFolder := TPath.DirectorySeparatorChar + SubFolder;
      Result := Result + SubFolder;
    end;
    Result := System.SysUtils.IncludeTrailingPathDelimiter(Result);
    if not DirectoryExists(Result) then
      if not ForceDirectories(Result) then
        Result := '';
  end;

end;

function ReadSetting(Section, Name: string; Default: variant): variant;
var
  IniFile: TIniFile;
  IniFilePathName: string;

begin

  IniFilePathName := GetAppDataFldPath + IOT_APP_INTERNAL_NAME + '.ini';

  try
    IniFile := TIniFile.Create(IniFilePathName);
    try
      case VarType(Default) of
        varByte, varShortInt, varSmallint, varInteger, varWord, varLongWord, varInt64:
          Result := IniFile.ReadInteger(Section, Name, Default);
        varSingle, varDouble, varCurrency:
          Result := IniFile.ReadFloat(Section, Name, Default);
        varBoolean:
          Result := IniFile.ReadBool(Section, Name, Default);
        varStrArg, varString:
          Result := IniFile.ReadString(Section, Name, Default);
      else
        Result := IniFile.ReadString(Section, Name, String(Default));
      end;
    finally
      IniFile.Free;
    end;
  except
    on E: Exception do
      Result := Default;
  end;

end;

procedure WriteSetting(Section, Name: string; Value: variant);
var
  IniFile: TIniFile;
  IniFilePathName: string;

begin

  IniFilePathName := GetAppDataFldPath + IOT_APP_INTERNAL_NAME + '.ini';
  IniFile := TIniFile.Create(IniFilePathName);

  try
    case VarType(Value) of
      varByte, varShortInt, varSmallint, varInteger, varWord, varLongWord, varInt64:
        IniFile.WriteInteger(Section, Name, Value);
      varSingle, varDouble, varCurrency:
        IniFile.WriteFloat(Section, Name, Value);
      varBoolean:
        IniFile.WriteBool(Section, Name, Value);
      varStrArg, varString:
        IniFile.WriteString(Section, Name, Value);
    else
      IniFile.WriteString(Section, Name, Value);
    end;
  finally
    IniFile.Free;
  end;

end;

procedure DeleteSetting(Section, Name: string);
var
  IniFile: TIniFile;
  IniFilePathName: string;

begin

  IniFilePathName := GetAppDataFldPath + IOT_APP_INTERNAL_NAME + '.ini';
  IniFile := TIniFile.Create(IniFilePathName);

  try
    IniFile.DeleteKey(Section, Name);
  finally
    IniFile.Free;
  end;

end;

{
procedure StrToFile(const FileName, SourceString: string);
var
  List: TStringList;

begin

  List := TStringList.Create;

  try
    List.Text := SourceString;
    List.SaveToFile(FileName);
  finally
    List.Free;
  end;

end;
}
{
  function JSONObjToStr(JSON: TJSONObject): string;
  var
    StringBuilder: TStringBuilder;

  begin

    Result := '';

    if Assigned(JSON) then
    begin
      StringBuilder := TStringBuilder.Create;
      JSON.ToChars(StringBuilder);
      Result := StringBuilder.ToString;
    end;

  end;
}
{
function IncludeTrailingSlash(const S: string): string;
var
  Index: smallint;

begin

  Result := S;

  if Result <> '' then
  begin
    Index := High(Result);
    if not ((Index >= Low(string)) and (Index <= High(Result)) and (Result[Index] = '/') and (ByteType(Result, Index) = mbSingleByte)) then
      Result := Result + '/';
  end;

end;
}
{
function GetAppTempFldPath: string;
begin

  Result := GetAppDataFldPath;

  if Result <> '' then
  begin
    Result := Result + 'temp' + TPath.DirectorySeparatorChar;
    if not DirectoryExists(Result) then
      if not ForceDirectories(Result) then
        Result := '';
  end;

end;
}

end.
