unit FrameRow;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.ListBox, FrameRowData,
  FrameNetwaveCam, FMX.Layouts;

type
  TfraRow = class(TFrame)
    panRow: TPanel;
    panCommands: TPanel;
    cmdDelete: TButton;
    panStatus: TPanel;
    lblStatus: TLabel;
    panSelected: TPanel;
    chkSelRow: TCheckBox;
    panHost: TPanel;
    lblHost: TLabel;
    panPort: TPanel;
    lblPort: TLabel;
    panCountry: TPanel;
    lblCountry: TLabel;
    panProvider: TPanel;
    lblProvider: TLabel;
    panCity: TPanel;
    lblCity: TLabel;
    panNotes: TPanel;
    txtNotes: TEdit;
    panPlacement: TPanel;
    cboPlacement: TComboBox;
    panRating: TPanel;
    cboRating: TComboBox;
    panAuth: TPanel;
    lblAuth: TLabel;
    layRowData: TLayout;
  private
    AHost: string;
    APort: integer;
    AAuth: string;
  public
    property Host: string read AHost write AHost;
    property Port: integer read APort write APort default 0;
    property Auth: string read AAuth write AAuth;
  end;

implementation

{$R *.fmx}

end.
