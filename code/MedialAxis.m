function varargout = MedialAxis(varargin)
% MEDIALAXIS M-file for MedialAxis.fig
%      MEDIALAXIS, by itself, creates a new MEDIALAXIS or raises the existing
%      singleton*.
%
%      H = MEDIALAXIS returns the handle to a new MEDIALAXIS or the handle to
%      the existing singleton*.
%
%      MEDIALAXIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEDIALAXIS.M with the given input arguments.
%
%      MEDIALAXIS('Property','Value',...) creates a new MEDIALAXIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MedialAxis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MedialAxis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MedialAxis

% Last Modified by GUIDE v2.5 19-Oct-2011 17:22:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MedialAxis_OpeningFcn, ...
                   'gui_OutputFcn',  @MedialAxis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MedialAxis is made visible.
function MedialAxis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MedialAxis (see VARARGIN)

% Choose default command line output for MedialAxis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MedialAxis wait for user response (see UIRESUME)
% uiwait(handles.figure1);
cla(handles.axes1);
axis('equal')
% --- Outputs from this function are returned to the command line.
function varargout = MedialAxis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global A dt Crust Skeleton p1 p2 p3 p4 p5 Junctions Pruning p6
p1=0;p2=0;p3=0;p4=0;p5=0;p6=0;
inputfile=uigetfile('*.shp','Choose the specific file :');
%Read Shapefile----------------------------------------
S = shaperead(inputfile);
A=[];
for i=1:size(S)
A=[A;S(i,1).X S(i,1).Y S(i,1).Id];
end
X=[A(:,1),A(:,2)];
t= find(A(:,3)==0);
tt=length(t);
t=[t zeros(tt,1)]; 
%--------------------------------------------------------
dt = DelaunayTri(X);%DT
e = edges(dt);%Triangulation edges
Crust=[];Skeleton=[];Junctions=zeros(tt,12);Pruning=[];
for ii=1:size(e,1);
   S=edgeAttachments(dt, e(ii,1),e(ii,2));%Simplices attached to specified edges
   attached_Simplices=S{:};
   if length(attached_Simplices)==2
       CC_VD1 = circumcenters(dt, attached_Simplices(1));%circumcenters coordinate of a specified Triangle
       CC_VD2 = circumcenters(dt, attached_Simplices(2));%circumcenters coordinate of a specified Triangle
       C_DT1=dt.X(e(ii,1),:);
       C_DT2=dt.X(e(ii,2),:);
       temp1=[1 C_DT1(1) C_DT1(2) C_DT1(1)^2+C_DT1(2)^2;
             1 C_DT2(1) C_DT2(2) C_DT2(1)^2+C_DT2(2)^2;
             1 CC_VD1(1) CC_VD1(2) CC_VD1(1)^2+CC_VD1(2)^2;
              1 CC_VD2(1) CC_VD2(2) CC_VD2(1)^2+CC_VD2(2)^2];
       det1=det(temp1);
       t1= find(A(:,1)==C_DT1(1)&A(:,2)==C_DT1(2));
       t2= find(A(:,1)==C_DT2(1)&A(:,2)==C_DT2(2));
       if  det1<0 %VD2 is out of circumcenters
           Crust=[Crust;C_DT1(1) C_DT1(2) C_DT2(1) C_DT2(2)];
       else  %VD2 is in circumcenters
           Skeleton=[Skeleton;CC_VD1(1) CC_VD1(2) CC_VD2(1) CC_VD2(2)];
                if A(t1,3)~=A(t2,3)
                    Pruning=[Pruning;CC_VD1(1) CC_VD1(2) CC_VD2(1) CC_VD2(2)];
                end
       end
       if A(t1,3)==0 && det1<0
           ttt= find(t(:,1)==t1);
           temp1=t(ttt,2)+1;
           Junctions(ttt,temp1:temp1+3)=[CC_VD1(1) CC_VD1(2) CC_VD2(1) CC_VD2(2)];
           t(ttt,2)=t(ttt,2)+4;
       elseif A(t2,3)==0 && det1<0
           ttt= find(t(:,1)==t2);
           temp1=t(ttt,2)+1;
           Junctions(ttt,temp1:temp1+3)=[CC_VD1(1) CC_VD1(2) CC_VD2(1) CC_VD2(2)];
           t(ttt,2)=t(ttt,2)+4;
       end
   else
       CC_VD1 = circumcenters(dt, attached_Simplices(1));%circumcenters coordinate of a specified Triangle
       if ~isinf(CC_VD1(1))
       ttt=pointLocation(dt,CC_VD1);
       end
       if ~isnan(ttt)
       Crust=[Crust;dt.X(e(ii,1),:) dt.X(e(ii,2),:)];
       end
   end
   
end
temp=[];P=[Pruning(:,1:2);Pruning(:,3:4)];
for ii=1:tt
   temp=zeros(6,3);
   temp(:,1)=Junctions(ii,1:2:12);
   temp(:,2)=Junctions(ii,2:2:12);
   for jj=1:6
       if temp(jj,3)==0 && temp(jj,3)~=-1
           temp1= find(temp(:,1)==temp(jj,1)&temp(jj,2)==temp(:,2));
           temp2=length(temp1);
           temp(temp1,3)=-1;
           temp(jj,3)=temp2;
       end
   end
   [B, IX] = sort(temp(:,3),'descend')
       temp=temp(IX,:);
       temp3=find( temp(:,3)>0);
       if length(temp3)==3
           temp4(ii,1:2:5)=temp(temp3,1);
           temp4(ii,2:2:6)=temp(temp3,2);
       else
           temp4(ii,1:2:3)=temp(temp3(1:2),1);
           temp4(ii,2:2:4)=temp(temp3(1:2),2);
           t1=find(P(:,1)==temp(temp3(3),1)&P(:,2)==temp(temp3(3),2))
           t2=find(P(:,1)==temp(temp3(4),1)&P(:,2)==temp(temp3(4),2))
           if t1==1
               temp4(ii,5:6)=temp(temp3(3),1:2);
           else
               temp4(ii,5:6)=temp(temp3(4),1:2);
           end
           
       end
   end
           
Junctions=[A(t(:,1),1:2) temp4];

axis([min(A(:,1))-10 max(A(:,1))+10 min(A(:,2))-10 max(A(:,2))+10])

% --------------------------------------------------------------------
function uitoggletool4_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global A p1
p1=1;
hold on
% scatter(A(:,1),A(:,2),'filled','MarkerFaceColor',[0.8471 0.1608 0], 'MarkerEdgeColor',[0.1686 0.5059 0.3373]);
scatter(A(:,1),A(:,2),5,'filled','MarkerFaceColor',[1 0 .4961], 'MarkerEdgeColor',[0.1686 0.5059 0.3373]);



% --------------------------------------------------------------------
function uitoggletool5_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dt p2
p2=1;
hold on
triplot(dt,'g');


% --------------------------------------------------------------------
function uitoggletool6_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global A p3
p3=1;
hold on
voronoi(A(:,1),A(:,2),'m');


% --------------------------------------------------------------------
function uitoggletool7_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Crust p4
p4=1;
hold on
plot([Crust(:,1)';Crust(:,3)'],[Crust(:,2)';Crust(:,4)'],'-b', 'LineWidth', 1.3);


% --------------------------------------------------------------------
function uitoggletool8_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Skeleton p5
p5=1;
hold on
plot([Skeleton(:,1)';Skeleton(:,3)'],[Skeleton(:,2)';Skeleton(:,4)'],'Color',[.2 1 .6], 'LineWidth', 3);


% --------------------------------------------------------------------
function uitoggletool4_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global A dt Crust Skeleton p1 p2 p3 p4 p5 Pruning p6
p1=0;
cla(handles.axes1);
if p2==1
    hold on
    triplot(dt,'g');
end
if p3==1
    hold on
    voronoi(A(:,1),A(:,2),'m');
end
if p4==1
    hold on
   plot([Crust(:,1)';Crust(:,3)'],[Crust(:,2)';Crust(:,4)'],'-b', 'LineWidth', 1.3);
end
if p5==1
    hold on
    plot([Skeleton(:,1)';Skeleton(:,3)'],[Skeleton(:,2)';Skeleton(:,4)'],'Color',[.2 1 .6], 'LineWidth', 3);
end
if p6==1
    hold on
    plot([Pruning(:,1)';Pruning(:,3)'],[Pruning(:,2)';Pruning(:,4)'],'Color',[.2 1 .6], 'LineWidth', 3);
end


% --------------------------------------------------------------------
function uitoggletool5_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global A dt Crust Skeleton p1 p2 p3 p4 p5 Pruning p6
p2=0;
cla(handles.axes1);
if p1==1
    hold on
    scatter(A(:,1),A(:,2),5,'filled','MarkerFaceColor',[1 0 .4961], 'MarkerEdgeColor',[0.1686 0.5059 0.3373]);
end
if p3==1
    hold on
    voronoi(A(:,1),A(:,2),'m');
end
if p4==1
    hold on
    plot([Crust(:,1)';Crust(:,3)'],[Crust(:,2)';Crust(:,4)'],'-b', 'LineWidth', 1.3);
end
if p5==1
    hold on
    plot([Skeleton(:,1)';Skeleton(:,3)'],[Skeleton(:,2)';Skeleton(:,4)'],'Color',[.2 1 .6], 'LineWidth', 3);
end
if p6==1
    hold on
    plot([Pruning(:,1)';Pruning(:,3)'],[Pruning(:,2)';Pruning(:,4)'],'Color',[.2 1 .6], 'LineWidth', 3);
end

% --------------------------------------------------------------------
function uitoggletool6_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global A dt Crust Skeleton p1 p2 p3 p4 p5 Pruning p6
p3=0;
cla(handles.axes1);
if p1==1
    hold on
    scatter(A(:,1),A(:,2),5,'filled','MarkerFaceColor',[1 0 .4961], 'MarkerEdgeColor',[0.1686 0.5059 0.3373]);
end
if p2==1
    hold on
    triplot(dt,'g');
end
if p4==1
    hold on
    plot([Crust(:,1)';Crust(:,3)'],[Crust(:,2)';Crust(:,4)'],'-b', 'LineWidth', 1.3);
end
if p5==1
    hold on
   plot([Skeleton(:,1)';Skeleton(:,3)'],[Skeleton(:,2)';Skeleton(:,4)'],'Color',[.2 1 .6], 'LineWidth', 3);
end
if p6==1
    hold on
    plot([Pruning(:,1)';Pruning(:,3)'],[Pruning(:,2)';Pruning(:,4)'],'Color',[.2 1 .6], 'LineWidth', 3);
end

% --------------------------------------------------------------------
function uitoggletool7_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global A dt Crust Skeleton p1 p2 p3 p4 p5 Pruning p6
p4=0;
cla(handles.axes1);
if p1==1
    hold on
    scatter(A(:,1),A(:,2),5,'filled','MarkerFaceColor',[1 0 .4961], 'MarkerEdgeColor',[0.1686 0.5059 0.3373]);
end
if p2==1
    hold on
    triplot(dt,'g');
end
if p3==1
    hold on
    voronoi(A(:,1),A(:,2),'m');
end
if p5==1
    hold on
    plot([Skeleton(:,1)';Skeleton(:,3)'],[Skeleton(:,2)';Skeleton(:,4)'],'Color',[.2 1 .6], 'LineWidth', 3);
end
if p6==1
    hold on
    plot([Pruning(:,1)';Pruning(:,3)'],[Pruning(:,2)';Pruning(:,4)'],'Color',[.2 1 .6], 'LineWidth', 3);
end

% --------------------------------------------------------------------
function uitoggletool8_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global A dt Crust Skeleton p1 p2 p3 p4 p5 Pruning p6
p5=0;
cla(handles.axes1);
if p1==1
    hold on
    scatter(A(:,1),A(:,2),5,'filled','MarkerFaceColor',[1 0 .4961], 'MarkerEdgeColor',[0.1686 0.5059 0.3373]);
end
if p2==1
    hold on
    triplot(dt,'g');
end
if p3==1
    hold on
    voronoi(A(:,1),A(:,2),'m');
end
if p4==1
    hold on
   plot([Crust(:,1)';Crust(:,3)'],[Crust(:,2)';Crust(:,4)'],'-b', 'LineWidth', 1.3);
end
if p6==1
    hold on
    plot([Pruning(:,1)';Pruning(:,3)'],[Pruning(:,2)';Pruning(:,4)'],'Color',[.2 1 .6], 'LineWidth', 3);
end

% --------------------------------------------------------------------
function uitoggletool9_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Pruning p6 A
p6=1;
hold on
plot([Pruning(:,1)';Pruning(:,3)'],[Pruning(:,2)';Pruning(:,4)'],'Color',[.2 1 .6], 'LineWidth', 3);
temp=find(A(:,3)==0);
    hold on
    scatter(A(temp,1),A(temp,2),70,'filled','MarkerFaceColor','r', 'MarkerEdgeColor',[0 0 0]);

% --------------------------------------------------------------------
function uitoggletool9_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global A dt Crust Skeleton p1 p2 p3 p4 p5 Pruning p6
p6=0;
cla(handles.axes1);
if p1==1
    hold on
    scatter(A(:,1),A(:,2),30,'filled','MarkerFaceColor',[1 0 .4961], 'MarkerEdgeColor',[0.1686 0.5059 0.3373]);
end
if p2==1
    hold on
    triplot(dt,'g');
end
if p3==1
    hold on
    voronoi(A(:,1),A(:,2),'m');
end
if p4==1
    hold on
   plot([Crust(:,1)';Crust(:,3)'],[Crust(:,2)';Crust(:,4)'],'-b', 'LineWidth', 1.3);
end
if p5==1
    hold on
    plot([Skeleton(:,1)';Skeleton(:,3)'],[Skeleton(:,2)';Skeleton(:,4)'],'Color',[.2 1 .6], 'LineWidth', 3);
end
temp=find(A(:,3)==0);
    hold on
    scatter(A(temp,1),A(temp,2),70,'filled','MarkerFaceColor','r', 'MarkerEdgeColor',[0 0 0]);





% --------------------------------------------------------------------
function uipushtool3_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Junctions A
for ii=1:size(Junctions,1)
    for jj=3:2:8
        hold on
        plot([Junctions(ii,1) Junctions(ii,jj)],[Junctions(ii,2) Junctions(ii,jj+1)],'Color',[.2 1 .6], 'LineWidth', 3)
    end
end
temp=find(A(:,3)==0);
    hold on
    scatter(A(temp,1),A(temp,2),70,'filled','MarkerFaceColor','r', 'MarkerEdgeColor',[0 0 0]);
