unit FrameRowData;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, System.Generics.Collections;

type
  TfraRowData = class(TFrame)
    panDeviceType: TPanel;
    lblDeviceType: TLabel;
    panDeviceData: TPanel;
  private
    ADataEx: TDictionary<string, TObject>;
  public
    property DataEx: TDictionary<string, TObject> read ADataEx write ADataEx;
  end;

implementation

{$R *.fmx}

end.
