program ReinforceTool;

uses
  Vcl.Forms,
  ReinforceForm in 'Tools\Forms\ReinforceForm.pas' {FormReinforce},
  FilesData in 'Src\Data\FilesData.pas',
  ReinforceEditorForm in 'Tools\Forms\ReinforceEditorForm.pas' {FormEditor},
  Defs in 'Tools\Data\Defs.pas',
  ShowForm in 'Tools\Forms\ShowForm.pas' {DataShow},
  FillItemsThread in 'Tools\Threads\FillItemsThread.pas',
  Load in 'Tools\Functions\Load.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormReinforce, FormReinforce);
  Application.CreateForm(TFormEditor, FormEditor);
  Application.CreateForm(TDataShow, DataShow);
  Application.Run;
end.
