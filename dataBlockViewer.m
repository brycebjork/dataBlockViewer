function varargout = dataBlockViewer(varargin)
% DATABLOCKVIEWER MATLAB code for dataBlockViewer.fig
%      DATABLOCKVIEWER, by itself, creates a new DATABLOCKVIEWER or raises the existing
%      singleton*.
%
%      H = DATABLOCKVIEWER returns the handle to a new DATABLOCKVIEWER or the handle to
%      the existing singleton*.
%
%      DATABLOCKVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATABLOCKVIEWER.M with the given input arguments.
%
%      DATABLOCKVIEWER('Property','Value',...) creates a new DATABLOCKVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dataBlockViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dataBlockViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dataBlockViewer

% Last Modified by GUIDE v2.5 17-Aug-2016 21:12:59

% Check for arguments
if nargin == 0
    error('Must include a data block');
end

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dataBlockViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @dataBlockViewer_OutputFcn, ...
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


% --- Executes just before dataBlockViewer is made visible.
function dataBlockViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dataBlockViewer (see VARARGIN)

% Choose default command line output for dataBlockViewer
handles.output = hObject;

% Save the data block to handles
handles.dataBlock = varargin{1};

% Update the main image axes with the image
handles.mainimage = imagesc(handles.dataBlock(:,:,1),'Parent',handles.mainImageAxes);
colormap(handles.mainImageAxes,'bone');
handles.rightimage = imagesc(NaN,'Parent',handles.rightImageAxes);
colormap(handles.rightImageAxes,'bone');
handles.topimage = imagesc(NaN,'Parent',handles.topImageAxes);
colormap(handles.topImageAxes,'bone');
handles.mainimagepoint = impoint(handles.mainImageAxes,100,100);
handles.topplot = plot(NaN,NaN,'Parent',handles.topPlotAxes);
handles.rightplot = plot(NaN,NaN,'Parent',handles.rightPlotAxes);
handles.timeplot = plot(NaN,NaN,'Parent',handles.timePlotAxes);
view(handles.rightPlotAxes,[90 90])
addNewPositionCallback(handles.mainimagepoint,@(pos) mainimagepoint_Callback(hObject,pos));
handles.cursorPos = [100 100];

% Update the slider
set(handles.timePlotSlider,'Min',1);
set(handles.timePlotSlider,'Max',size(handles.dataBlock,3));
set(handles.timePlotSlider,'Value',1);
set(handles.timePlotSlider,'Callback',@(h,ev) timeslider_Callback(hObject,h))
handles.zindex = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dataBlockViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function timeslider_Callback(hObject,hslider)
    handles = guidata(hObject);
    handles.zindex = round(get(hslider,'Value'));
    guidata(hObject,handles);
    
    updateEverything(hObject);

function mainimagepoint_Callback(hObject,pos)
    handles = guidata(hObject);
    handles.cursorPos = round(pos);
    guidata(hObject,handles);
    
    updateEverything(hObject);
    
function updateEverything(hObject)
    handles = guidata(hObject);
    
    % Update time plot
    ytime = handles.dataBlock(handles.cursorPos(2),handles.cursorPos(1),:);
    set(handles.timeplot,'XData',1:size(handles.dataBlock,3));
    set(handles.timeplot,'YData',ytime);
    
    % Update main plot
    set(handles.mainimage,'CData',handles.dataBlock(:,:,handles.zindex));
    
    % Update top plot
    ytop = handles.dataBlock(handles.cursorPos(2),:,handles.zindex);
    set(handles.topplot,'XData',1:numel(ytop));
    set(handles.topplot,'YData',ytop);
    
    % Update top image
    lowerBound = handles.cursorPos(2)-25;
    upperBound = handles.cursorPos(2)+25;
    ytop = handles.dataBlock(lowerBound:upperBound,:,handles.zindex);
    set(handles.topimage,'CData',ytop);
    xlim(handles.topImageAxes,[1 size(ytop,2)])
    ylim(handles.topImageAxes,[1 size(ytop,1)])
    
    % Update right plot
    yright = handles.dataBlock(:,handles.cursorPos(1),handles.zindex);
    set(handles.rightplot,'XData',1:numel(yright));
    set(handles.rightplot,'YData',yright);
    
    % Update right image
    lowerBound = handles.cursorPos(1)-25;
    upperBound = handles.cursorPos(1)+25;
    yright = handles.dataBlock(:,lowerBound:upperBound,handles.zindex);
    set(handles.rightimage,'CData',yright);
    xlim(handles.rightImageAxes,[1 size(yright,2)])
    ylim(handles.rightImageAxes,[1 size(yright,1)])
    
    guidata(hObject,handles);


% --- Outputs from this function are returned to the command line.
function varargout = dataBlockViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function timePlotSlider_Callback(hObject, eventdata, handles)
% hObject    handle to timePlotSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function timePlotSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timePlotSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
