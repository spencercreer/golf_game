function varargout = golf2(varargin)
% GOLF2 MATLAB code for golf2.fig
%      GOLF2, by itself, creates a new GOLF2 or raises the existing
%      singleton*.
%
%      H = GOLF2 returns the handle to a new GOLF2 or the handle to
%      the existing singleton*.
%
%      GOLF2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GOLF2.M with the given input arguments.
%
%      GOLF2('Property','Value',...) creates a new GOLF2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before golf2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to golf2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help golf2

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @golf2_OpeningFcn, ...
                   'gui_OutputFcn',  @golf2_OutputFcn, ...
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


% --- Executes just before golf2 is made visible.
function golf2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to golf2 (see VARARGIN)


% Choose default command line output for golf2
handles.output = hObject;

% Update handles structure and initialize handles
handles.power = 50;
handles.distance = 300;
handles.windSpeed = 20;
handles.windDir = 0;
handles.angle = 90;
guidata(hObject, handles);

updatefig(hObject, eventdata, handles)
updatefig2(hObject, eventdata, handles)

% UIWAIT makes golf2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = golf2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%*************************************************************************


%***************************SWING BUTTON**********************************

% --- Executes on SWING BUTTON press in Swing.
function Swing_Callback(hObject, eventdata, handles)% SWING BUTTON
% hObject    handle to Swing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updatefig(hObject, eventdata, handles)
updatefig2(hObject, eventdata, handles)

lb = get(handles.clubs,'Value');% Club listbox selection

% Switch statement determining which club is selected
switch lb
    case 1
        club = 'D';
    case 2
        club = '2W';
    case 3
        club = '3W';
    case 4
        club = '4W';
    case 5
        club = '5W';
    case 6
        club = '6W';
    case 7
        club = '7W';
    case 8
        club = '3I';
    case 9
        club = '4I';
    case 10
        club = '5I';
    case 11
        club = '6I';
    case 12
        club = '7I';
    case 13
        club = '8I';
    case 14
        club = '9I';
    case 15
        club = 'W';
end

% Function that determines initial x,y,z velocity and spin based on club
% selection and swing power fraction        
fraction = handles.power/100;% Convert swing power percentage to fraction
[vel spin] = club_strike(club,fraction)

% ODE45 function for golf eom
t0 = 0;
tf = 100;
tspan = [t0 tf];

Vwx = handles.windSpeed*sind(handles.windDir);
Vwy = 0;
Vwz = handles.windSpeed*cosd(handles.windDir);

vx = vel(1)*sind(handles.angle)
vy = vel(2)
vz = vel(1)*cosd(handles.angle)

omega_x = spin(3)*cosd(handles.angle);
omega_y = spin(2);
omega_z = spin(3)*sind(handles.angle);

[tout,out] = ode45(@golf_eom,tspan,[0,0,0,vx,vy,vz,Vwx,Vwy,Vwz,omega_x,omega_y,omega_z]);

xout = out(:,1);
yout = out(:,2);
zout = out(:,3);

% indicesForPositive = find(out(:,2) >= 0); %gives you indices where y is positive i.e. above ground
% out = out(indicesForPositive,:); %returns the matrix out with only the rows associated with y > 0
% 
% x_swingframe = out(:,1); % take the x's from the output vector
% y_swingframe = out(:,2); % take the y's from the output vector
% z_swingframe = out(:,3); % take the z's from the output vector
% 
% % rotating back to world frame:
% A = [cosd(swingangle_deg) -sind(swingangle_deg);  sind(swingangle_deg) cosd(swingangle_deg)]; % be careful how you define positive angles!!!
% vectors_swingframe = [z_swingframe'; x_swingframe']; %making a 2 by N matrix
% vectors_worldframe = A*vectors_swingframe; %rotating the vectors from the swing frame to the world frame
%    
% x_worldframe = vectors_worldframe(1,:); % extracting out the x's
% z_worldframe = vectors_worldframe(2,:); % extracting out the z's

i = 1;
axes(handles.course)
while yout(i) >= 0
    hold on
    plot(zout(i:i+1),xout(i:i+1),'r','Linewidth',2)
    pause(0.01)
    i = i+1;
end

i = 1;
axes(handles.axes3)
while yout(i) >= 0
    hold on
    plot (handles.axes3,xout(i:i+1), yout(i:i+1),'r','Linewidth',2) 
    pause(0.01)
    i = i+1;
end

% Update handles structure
guidata(hObject, handles);
%*************************************************************************


%**************************CLUB LISTBOX************************************

% --- Executes on selection change in clubs.
function clubs_Callback(hObject, eventdata, handles)
% hObject    handle to clubs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns clubs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from clubs

updatefig(hObject, eventdata, handles)% update figure
updatefig2(hObject, eventdata, handles)% update figure

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function clubs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clubs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%**************************************************************************


%****************************WINDSPEED TEXT BOX****************************

% --- Executes on WIND SPEED TEXT EDIT BOX.
function windspeed_Callback(hObject, eventdata, handles)
% hObject    handle to windspeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of windspeed as text
%        str2double(get(hObject,'String')) returns contents of windspeed as a double

handles.windSpeed = str2double(get(hObject,'String'))% Update wind speed when user types it in.
updatefig(hObject, eventdata, handles)% update figure
updatefig2(hObject, eventdata, handles)% update figure

% Update handles structure
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function windspeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windspeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%**************************************************************************



function holedistance_Callback(hObject, eventdata, handles)
% hObject    handle to holedistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of holedistance as text
%        str2double(get(hObject,'String')) returns contents of holedistance as a double

handles.distance = str2double(get(hObject,'String'))% Update handles.distance when user types in value

updatefig(hObject, eventdata, handles)% Update figure with new hole distance
updatefig2(hObject, eventdata, handles)% update figure

% Update handles structure
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function holedistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to holedistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%**************************************************************************


%*********************WIND DIRECTION SLIDER AND EDIT BOX*******************

% --- Executes on WIND DIRECTION SLIDER movement.
function WindDirSlider_Callback(hObject, eventdata, handles)% WIND DIRECTION SLIDER
% hObject    handle to WindDirSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Update value of wind direction angle
handles.windDir = get(hObject,'Value');% set wind direction to value of wind_dir slider
set(handles.windDirText,'string',num2str(handles.windDir));% update SwingAng edit box to value
updatefig(hObject, eventdata, handles)% update figure
updatefig2(hObject, eventdata, handles)% update figure

% Update handles structure
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function WindDirSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WindDirSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function windDirText_Callback(hObject, eventdata, handles)
% hObject    handle to windDirText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of windDirText as text
%        str2double(get(hObject,'String')) returns contents of windDirText as a double

handles.windDir = str2double(get(hObject,'String'));% update WindDir slider
set(handles.WindDirSlider,'Value',handles.windDir);% update wind direction slider
updatefig(hObject, eventdata, handles)% update figure
updatefig2(hObject, eventdata, handles)% update figure

% Update handles structure
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function windDirText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windDirText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% ************************************************************************


% ***************SWING ANGLE SLIDER AND EDIT BOX**************************

% --- Executes on SWING ANGLE SLIDER movement.
function SwingAngleSlider_Callback(hObject, eventdata, handles)% SWING SLIDER
% hObject    handle to SwingAngleSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Update value of swing angle
handles.angle = get(hObject,'Value');% SwingAngle slider
set(handles.SwingAng,'string',num2str(handles.angle));% update SwingAng edit box to value
updatefig(hObject, eventdata, handles)% update figure
updatefig2(hObject, eventdata, handles)% update figure

% Update handles structure
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function SwingAngleSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SwingAngleSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on SWING ANGLE EDIT TEXT BOX.
function SwingAng_Callback(hObject, eventdata, handles)
% hObject    handle to SwingAng (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SwingAng as text
%        str2double(get(hObject,'String')) returns contents of SwingAng as a double

handles.angle = str2double(get(hObject,'String'));% update handles.angle when user types in value
set(handles.SwingAngleSlider,'Value',handles.angle);% update SwingAngleSlider to entered value
updatefig(hObject, eventdata, handles)% update figure
updatefig2(hObject, eventdata, handles)% update figure

% Update handles structure
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function SwingAng_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SwingAng (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%*************************************************************************


%*********************POWER SLIDER AND EDIT BOX***************************

% --- Executes on POWER SLIDER movement.
function powSlider_Callback(hObject, eventdata, handles)% POWER SLIDER
% hObject    handle to powSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.power = get(hObject,'Value');
set(handles.SwingPow,'string',num2str(handles.power));% update SwingPow edit box to value
updatefig(hObject, eventdata, handles)% update figure
updatefig2(hObject, eventdata, handles)% update figure

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function powSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to powSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on POWER EDIT TEXT BOX.
function SwingPow_Callback(hObject, eventdata, handles)
% hObject    handle to SwingPow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SwingPow as text
%        str2double(get(hObject,'String')) returns contents of SwingPow as a double

handles.power = str2double(get(hObject,'String'));% Update handles.power when user types in value
set(handles.powSlider,'Value',handles.power);% update power_slider to entered value
updatefig(hObject, eventdata, handles)% update figure
updatefig2(hObject, eventdata, handles)% update figure

% Update handles structure
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function SwingPow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SwingPow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%*************************************************************************

% Update top view coarse figure
function updatefig(hObject, eventdata, handles)
axes (handles.course)
cla % clear
axis([-175 175 0 350])% [xmin xmax ymin ymax]
grid on % Show grid
rectangle('Position',[-2.5 handles.distance-2.5 5 5],'Curvature',[1 1],'FaceColor','k', 'EdgeColor','k')%hole
line([0 0],[handles.distance handles.distance+20], 'Color', 'k','Linewidth',2)%flag pole
x = [0 0 10];
y = [handles.distance+10 handles.distance+20 handles.distance+15];
patch(x,y,'red')%flag
hold on
quiver(0,0,handles.power*cosd(handles.angle),handles.power*sind(handles.angle),'linewidth',2, 'maxheadsize',20,'color','k')
quiver(50,150,handles.windSpeed*cosd(handles.windDir),handles.windSpeed*sind(handles.windDir),'linewidth',2, 'maxheadsize',20,'color','b')

% Update earth view coarse figure
function updatefig2(hObject, eventdata, handles)
axes (handles.axes3)
cla % clear
axis([-30 350 0 50])% [xmin xmax ymin ymax]
%rectangle('Position',[-30 -5 380 5],'FaceColor',[0.47 0.67 0.19])
line([handles.distance handles.distance],[0 3], 'Color', 'k','Linewidth',2)%flag pole
x = [handles.distance handles.distance handles.distance+15];
y = [3 2 2.5];
patch(x,y,'red')%flag
rectangle('Position',[-4.5 2 9 1],'Curvature',[1 1],'FaceColor',[0.7 0.6 0], 'EdgeColor', [0.6 0.5 0])%head
line([0 0],[1 2], 'Color', 'k','Linewidth',2)%body
line([-4 0],[0 1], 'Color', 'k','Linewidth',2)%leg
line([0 4],[1 0], 'Color', 'k','Linewidth',2)%leg
line([0 6],[1.25 2], 'Color', 'k','Linewidth',2)%arm
line([0 -6],[1.25 2], 'Color', 'k','Linewidth',2)%arm
hold on
