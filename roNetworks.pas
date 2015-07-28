unit roNetworks;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, roChildWin, ComCtrls, Menus, ActnList, SQLiteData;

type
  TNetworkWin = class(TChildWin)
    MainMenu1: TMainMenu;
    oView: TTreeView;
    ActionList1: TActionList;
    aNewNetwork: TAction;
    aNewServer: TAction;
    Network1: TMenuItem;
    Newserver1: TMenuItem;
    Addnetwork1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Addnetwork2: TMenuItem;
    Addserver1: TMenuItem;
    aDelete: TAction;
    N1: TMenuItem;
    Delete1: TMenuItem;
    N2: TMenuItem;
    Delete2: TMenuItem;
    aProperties: TAction;
    N3: TMenuItem;
    Properties1: TMenuItem;
    N4: TMenuItem;
    Properties2: TMenuItem;
    aConnect: TAction;
    N5: TMenuItem;
    Connect1: TMenuItem;
    N6: TMenuItem;
    Connect2: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure aNewNetworkExecute(Sender: TObject);
    procedure oViewExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure oViewDeletion(Sender: TObject; Node: TTreeNode);
    procedure aNewServerExecute(Sender: TObject);
    procedure oViewEdited(Sender: TObject; Node: TTreeNode; var S: String);
    procedure aDeleteExecute(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure aPropertiesExecute(Sender: TObject);
    procedure oViewDblClick(Sender: TObject);
    procedure aConnectExecute(Sender: TObject);
  private
    procedure Refresh;

    function AddNetworkNode(rs:TSQLiteStatement):TTreeNode;
    function AddServerNode(rs:TSQLiteStatement;p:TTreeNode):TTreeNode;
  end;

  TAmalgamation=(alNetwork,alServer);

  TNodeData=class
   public
    expanded:boolean;
    objtype:TAmalgamation;
    id:integer;
  end;

const
 TableName:array[TAmalgamation] of string=
  ('Network','Server');

var
  NetworkWin: TNetworkWin;

implementation

uses roMain, roNetworkProps, roServerProps, roConWin, roStuff;

{$R *.dfm}

procedure TNetworkWin.FormShow(Sender: TObject);
begin
  inherited;
  Refresh;
end;

procedure TNetworkWin.aNewNetworkExecute(Sender: TObject);
var
  rs:TSQLiteStatement;
begin
  inherited;
  with NetworkPropWin do
   begin
    aName.Text:='';
    aDescription.Text:='';
    aNick.Text:='';
    aAltNick.Text:='';
    aFullName.Text:='';
    aEmail.Text:='';
   end;
  if NetworkPropWin.ShowModal=mrOk then
   begin
    with NetworkPropWin do
     begin
      MainWin.dbCon.Execute('INSERT INTO Network (name,description,nick,altnicks,fullname,email,created,modified) VALUES (?,?,?,?,?,?,?,?)',
       [aName.Text,
        aDescription.Text,
        aNick.Text,
        aAltNick.Text,
        aFullName.Text,
        aEmail.Text,
        VarFromDateTime(Now),
        VarFromDateTime(Now)]);
     end;
    rs:=TSQLiteStatement.Create(MainWin.dbCon,
      'SELECT * FROM Network WHERE id=?',[MainWin.dbCon.LastInsertRowID]);
    try
      oView.Selected:=AddNetworkNode(rs);
      if NetworkPropWin.DoConnect then aConnect.Execute;
    finally
      rs.Free;
    end;
  end;
end;

procedure TNetworkWin.Refresh;
var
  rs:TSQLiteStatement;
begin
  oView.Items.BeginUpdate;
  try
    oView.Items.Clear;
    rs:=TSQLiteStatement.Create(MainWin.dbCon,
      'SELECT * FROM Network');
    try
      while rs.Read do AddNetworkNode(rs);
    finally
      rs.Free;
    end;
  finally
    oView.Items.EndUpdate;
  end;
end;

function TNetworkWin.AddNetworkNode(rs:TSQLiteStatement):TTreeNode;
var
  n:TTreeNode;
  nd:TNodeData;
begin
  n:=oView.Items.Add(nil,rs.GetStr('name'));
  n.HasChildren:=true;
  n.ImageIndex:=iiNetwork;
  n.SelectedIndex:=iiNetwork;
  nd:=TNodeData.Create;
  n.Data:=nd;
  nd.expanded:=false;
  nd.objtype:=alNetwork;
  nd.id:=rs.GetInt('id');
  Result:=n;
end;

function TNetworkWin.AddServerNode(rs:TSQLiteStatement;p:TTreeNode):TTreeNode;
var
  n:TTreeNode;
  nd:TNodeData;
begin
  n:=oView.Items.AddChild(p,rs.GetStr('name'));
  //n.HasChildren:=false;
  n.ImageIndex:=iiServer;
  n.SelectedIndex:=iiServer;
  nd:=TNodeData.Create;
  n.Data:=nd;
  nd.expanded:=false;
  nd.objtype:=alServer;
  nd.id:=rs.GetInt('id');
  Result:=n;
end;

procedure TNetworkWin.oViewExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
var
  rs:TSQLiteStatement;
  nd:TNodeData;
begin
  inherited;
  if Node.Data<>nil then
   begin
    nd:=Node.Data;
    if not(nd.expanded) then
     begin
      Node.HasChildren:=false;
      nd.expanded:=true;
      case nd.objtype of
        alNetwork:
         begin
          oView.Items.BeginUpdate;
          try
            rs:=TSQLiteStatement.Create(MainWin.dbCon,
              'SELECT * FROM Server WHERE network_id=?'+
              ' ORDER BY name',[nd.id]);
            try
              while rs.Read do AddServerNode(rs,Node);
            finally
              rs.Free;
            end;
          finally
            oView.Items.EndUpdate;
          end;
         end;
        alServer:;
      end;
     end;
   end;
end;

procedure TNetworkWin.oViewDeletion(Sender: TObject; Node: TTreeNode);
begin
  inherited;
  if Node.Data<>nil then TNodeData(Node.Data).Free;
end;

procedure TNetworkWin.aNewServerExecute(Sender: TObject);
var
  n:TTreeNode;
  rs:TSQLiteStatement;
begin
  inherited;
  n:=oView.Selected;
  while (n<>nil) and (n.Data<>nil) and
    not(TNodeData(n.Data).objtype=alNetwork) do
      n:=n.Parent;
  if n=nil then
   begin
    Application.Messagebox(
      PChar(roNoNetwork),PChar(AppName),MB_OK or MB_ICONINFORMATION);
   end
  else
   begin
    with ServerPropWin do
     begin
      aName.Text:='';
      aDescription.Text:='';
      aHost.Text:='';
      aPort.Text:='';
      aPorts.Text:='';
     end;
    if ServerPropWin.ShowModal=mrOk then
     begin
      with ServerPropWin do
        MainWin.dbCon.Execute(
          'INSERT INTO Server (network_id,name,description,host,'+
          'defaultport,ports,connectusermode,created,modified)'+
          ' VALUES (?,?,?,?,?,?,?,?,?)',
          [TNodeData(n.Data).id,
           aName.Text,
           aDescription.Text,
           aHost.Text,
           StrToIntDef(aPort.Text,6667),
           aPorts.Text,
           8,
           VarFromDateTime(Now),
           VarFromDateTime(Now)]);
      rs:=TSQLiteStatement.Create(MainWin.dbCon,
        'SELECT * FROM Server WHERE id=?',[MainWin.dbCon.LastInsertRowID]);
      try
        oView.Selected:=AddServerNode(rs,n);
      finally
        rs.Free;
      end;
      if ServerPropWin.DoConnect then aConnect.Execute;
     end;

    //new server
   end;
end;

procedure TNetworkWin.oViewEdited(Sender: TObject; Node: TTreeNode;
  var S: String);
var
  nd:TNodeData;
begin
  inherited;
  if Node.Data<>nil then
   begin
    nd:=Node.Data;
    MainWin.dbCon.Execute(
      'UPDATE '+TableName[nd.objtype]+' SET name=? WHERE id=?',[s,nd.id]);
   end;
end;

procedure TNetworkWin.aDeleteExecute(Sender: TObject);
var
  n:TTreeNode;
  nd:TNodeData;
begin
  inherited;
  n:=oView.Selected;
  if not(n=nil) and not(n.Data=nil) then
   begin
    nd:=n.Data;
    if Application.MessageBox(PChar(roDeleteItem),
      PChar(AppName),MB_OKCANCEL or MB_ICONQUESTION)=idOk then
     begin
      MainWin.dbCon.Execute(
       'DELETE FROM '+TableName[nd.objtype]+
       ' WHERE id=?',[nd.id]);
      n.Delete;
     end;
   end;
end;

procedure TNetworkWin.PopupMenu1Popup(Sender: TObject);
begin
  inherited;
  //kludge!
  oView.Selected:=oView.Selected;
end;

procedure TNetworkWin.aPropertiesExecute(Sender: TObject);
var
  n:TTreeNode;
  nd:TNodeData;
  rs:TSQLiteStatement;
begin
  inherited;
  n:=oView.Selected;
  if (n<>nil) and (n.Data<>nil) then
   begin
    nd:=n.Data;
    case nd.objtype of
     alNetwork:
      begin
       rs:=TSQLiteStatement.Create(MainWin.dbCon,
         'SELECT * FROM Network WHERE id=?',[nd.id]);
       try
         with NetworkPropWin do
          begin
           aName.Text:=rs.GetStr('name');
           aDescription.Text:=rs.GetStr('description');
           aNick.Text:=rs.GetStr('nick');
           aAltNick.Text:=rs.GetStr('altnicks');
           aFullName.Text:=rs.GetStr('fullname');
           aEmail.Text:=rs.GetStr('email');
          end;
       finally
         rs.Free;
       end;
       if NetworkPropWin.ShowModal=mrOk then
        begin
         with NetworkPropWin do
          begin
           MainWin.dbCon.Execute('UPDATE Network SET name=?,description=?,'+
            'nick=?,altnicks=?,fullname=?,email=?,modified=? WHERE id=?',
            [aName.Text,
             aDescription.Text,
             aNick.Text,
             aAltNick.Text,
             aFullName.Text,
             aEmail.Text,
             VarFromDateTime(Now),
             nd.id]);
           n.Text:=aName.Text;
           if DoConnect then aConnect.Execute;
          end;
        end;
      end;
     alServer:
      begin
       rs:=TSQLiteStatement.Create(MainWin.dbCon,
         'SELECT * FROM Server WHERE id=?',[nd.id]);
       with ServerPropWin do
        begin
         aName.Text:=rs.GetStr('name');
         aDescription.Text:=rs.GetStr('description');
         aHost.Text:=rs.GetStr('host');
         aPort.Text:=IntToStr(rs.GetInt('defaultport'));
         aPorts.Text:=rs.GetStr('ports');
        end;
       if ServerPropWin.ShowModal=mrOk then
        begin
         with ServerPropWin do
          begin
           MainWin.dbCon.Execute('UPDATE Server SET name=?,description=?,'+
            'host=?,defaultport=?,ports=?,modified=? WHERE id=?',
            [aName.Text,
             aDescription.Text,
             aHost.Text,
             StrToIntDef(aPort.Text,6667),
             aPorts.Text,
             VarFromDateTime(Now),
             nd.id]);
           n.Text:=aName.Text;
           if DoConnect then aConnect.Execute;
          end;
        end;
      end;
    end;
   end;
end;

procedure TNetworkWin.oViewDblClick(Sender: TObject);
begin
  inherited;
  aProperties.Execute;
end;

procedure TNetworkWin.aConnectExecute(Sender: TObject);
var
 n:TTreeNode;
 nd:TNodeData;
 f:TConnectionWin;
begin
  inherited;
 //
 f:=TConnectionWin.Create(Application);
 n:=oView.Selected;
 if not(n=nil) and not(n.Data=nil) then
  begin
   nd:=n.Data;
   case nd.objtype of
    alNetwork:f.DataByNetwork(nd.id);
    alServer:f.DataByServer(nd.id);
   end;
   //f.DoConnect;
   f.ConnectOnComplete:=true;
  end;
end;

end.
