unit FrameNetwaveCam;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FrameRowData, FMX.Controls.Presentation;

type
  TfraNetwaveCam = class(TfraRowData)
    panName: TPanel;
    lblName: TLabel;
    panCapture: TPanel;
    cmdShowCature: TButton;
    lblMails: TLabel;
    panAlias: TPanel;
    lblAlias: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fraNetwaveCam: TfraNetwaveCam;

implementation

{$R *.fmx}

end.
