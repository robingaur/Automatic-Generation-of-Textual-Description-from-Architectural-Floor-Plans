function varargout = FloorPlanTextualDescription(varargin)
% FLOORPLANTEXTUALDESCRIPTION MATLAB code for FloorPlanTextualDescription.fig
%      FLOORPLANTEXTUALDESCRIPTION, by itself, creates a new FLOORPLANTEXTUALDESCRIPTION or raises the existing
%      singleton*.
%
%      H = FLOORPLANTEXTUALDESCRIPTION returns the handle to a new FLOORPLANTEXTUALDESCRIPTION or the handle to
%      the existing singleton*.
%
%      FLOORPLANTEXTUALDESCRIPTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLOORPLANTEXTUALDESCRIPTION.M with the given input arguments.
%
%      FLOORPLANTEXTUALDESCRIPTION('Property','Value',...) creates a new FLOORPLANTEXTUALDESCRIPTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FloorPlanTextualDescription_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FloorPlanTextualDescription_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FloorPlanTextualDescription

% Last Modified by GUIDE v2.5 16-Nov-2016 14:48:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FloorPlanTextualDescription_OpeningFcn, ...
                   'gui_OutputFcn',  @FloorPlanTextualDescription_OutputFcn, ...
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


% --- Executes just before FloorPlanTextualDescription is made visible.
function FloorPlanTextualDescription_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FloorPlanTextualDescription (see VARARGIN)

% Choose default command line output for FloorPlanTextualDescription
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FloorPlanTextualDescription wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FloorPlanTextualDescription_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in input_img.
function input_img_Callback(hObject, eventdata, handles)
% hObject    handle to input_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.*';'*.tiff';'*.png';'*.jpg';'*.jpeg'},'File Selector');
 fullFileName =fullfile(pathname,filename);
 setappdata(0,'fullFileName',fullFileName);
 setappdata(0,'filename',filename);
 input_img = imread(fullFileName);
axes(handles.axes1);
imshow(input_img);



% --- Executes on button press in start_pro.
function start_pro_Callback(hObject, eventdata, handles)
% hObject    handle to start_pro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input_img = getappdata(0,'fullFileName');

%% reading image %%
image = imread(input_img);
%image = imread('1.jpg');
%figure, imshow(image);

%% Converting image to binary image %%
image_binary = im2bw(image);

%% taking Complement of the image %%
image_binary_c = imcomplement(image_binary);


%% Applying Connected Components on complement       binary image %%
pixels = 1000000;

while max(pixels) > 80
   cc = bwconncomp(image_binary_c);
   pixels = cellfun(@numel, cc.PixelIdxList);
   [biggest, idx] = max(pixels);
   image_binary_c(cc.PixelIdxList{idx}) = 0;  
end

%% Showing image without graphics componencts %%
% figure, imshow(imcomplement(image_binary_c)); title('Image without graphics component');

%% Applying OCR to read the text from the image %%
results = ocr(image_binary_c, 'TextLayout', 'Block');
results.Text;
image = double(imcomplement(image_binary_c));

%% Showing the bounded boxes on the image %%
n = 0;
Bedroom = 'Bedroom';
B = char(Bedroom);

targets = '?bedroom?kitchen?hallway?storage?laundry?entry?living room?douage?garage?doublegarage?conference?';
selectedWords = {'0', 0, 0, 0, 0, 0};
digitArea = {0, 0, 0};
i = 1; j=1;
for n = 1:size(results.Words)
    word = results.Words{n};
    newword = word(isstrprop(word,'alphanum'));
    if(isempty(newword) == 1 || length(newword)<=1)
        continue
    end
    switch newword(1)
        case 'B'
            newword = 'Bedroom';
        case 'K'
            newword = 'Kitchen';
        case 'k'
            newword = 'Kitchen';
        case 'S'
            newword = 'Storage';
        case 'E'
            newword = 'Entry';
        case 'L'
            newword = 'Living Room';
        case 'H'
            newword = 'Hallway';
    end
    wordBBox = results.WordBoundingBoxes(n,:);
    image = insertObjectAnnotation(image, 'rectangle', wordBBox, newword);
    newword = strcat('?', newword, '?');
    %disp(newword); disp(wordBBox);
    if ~isempty(strfind(targets, lower(newword)))
        selectedWords{i, 1} = upper(strrep(newword, '?', ''));
        selectedWords{i, 2} = wordBBox(1);
        selectedWords{i, 3} = wordBBox(2);
        selectedWords{i, 4} = wordBBox(3);
        selectedWords{i, 5} = wordBBox(4);
        selectedWords{i, 6} = 0;
        i = i+1;
    end
    
    %% finding area %%
    digit = regexp(newword, '(\d+)', 'match');
    if ~isempty(digit)
        digitArea{j, 1} = str2double(char(digit));
        digitArea{j, 2} = wordBBox(1);
        digitArea{j, 3} = wordBBox(2);
        j=j+1;
    end
end

% figure, imshow(image);
%disp(selectedWords);

s = selectedWords(:, 1);
map = containers.Map(selectedWords(:, 1), selectedWords(:, 6));
for i=1:length(s)
    map(char(s(i))) = map(char(s(i))) + 1;
end
s= keys(map);
text = 'In this architectural floor plans, there are';
for i=1:length(s)
    if (map(char(s(i))) == 1)
        text = strcat(text, '?', 'one', '?', char(s(i)), ',');
    else
        text = strcat(text, '?', numbers(map(char(s(i)))), '?', plural(char(s(i))), ',');
    end
end
text(length(text)) = '.';

%% 2nd Part %%
breadth = size(image);
breadth = breadth(1);
mid = breadth/2;

%% For Upper Part %%
array1 = {'0', 0}; i=1;
array2 = {'0', 0}; j=1;

for n=1:length(selectedWords(:, 1))
    if (mid > cell2mat(selectedWords(n, 3)))
        array1{i, 1} = char(selectedWords(n, 1));
        array1(i, 2) = selectedWords(n, 2);
        i=i+1;
    else
        array2{j, 1} = char(selectedWords(n, 1));
        array2(j, 2) = selectedWords(n, 2);
        j=j+1;
    end
end

array1 = mysort(array1, 2);
array2 = mysort(array2, 2);

text = strcat(text, '?');
for i=1:length(array1(:, 1))
    if (i==1)
        text = strcat(text, char(array1{i, 1}), '?is the upper left most room in the floor plan.?');
    else
        text = strcat(text, char(array1{i, 1}), '?is the right adjancent room of?', char(array1{i-1, 1}), '.?');
    end
end
text = strcat(text, char(array1{length(array1(:, 1)), 1}), '?is also an upper right most room of the floor plan.?');

for i=1:length(array2(:, 1))
    if (i==1)
        text = strcat(text, char(array2{i, 1}), '?is the lower left most room in the floor plan.?');
    else
        text = strcat(text, char(array2{i, 1}), '?is the right adjancent room of?', char(array2{i-1, 1}), '.?');
    end
end
text = strcat(text, char(array2{length(array2(:, 1)), 1}), '?is also an lower right most room of the floor plan.?');

%% Working on Area %%
%disp(digitArea);

for n=1:length(digitArea(:, 1));
    for i=1:length(selectedWords(:, 1))
        if (cell2mat(digitArea(n, 2)) > cell2mat(selectedWords(i, 2)) - 5 && cell2mat(digitArea(n, 2)) < cell2mat(selectedWords(i, 2)) + cell2mat(selectedWords(i, 4)) && cell2mat(digitArea(n, 3)) > cell2mat(selectedWords(i, 3)) + cell2mat(selectedWords(i, 5)) && cell2mat(digitArea(n, 3)) < cell2mat(selectedWords(i, 3)) + 2*cell2mat(selectedWords(i, 5)))
            text = strcat(text, '?The area of?' , char(selectedWords(i, 1)), '?is?', int2str(cell2mat(digitArea(n, 1))), '?square unit.');
        end
    end
end


text = strrep(text, '?', ' ');
set(handles.text2, 'string', text);
setappdata(0,'textDescription',text);





% --- Executes on button press in save_desc.
function save_desc_Callback(hObject, eventdata, handles)
% hObject    handle to save_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
text = getappdata(0,'textDescription');
[file,path] = uiputfile('textDescription.txt','Save the Text Description');
if exist(file, 'file')
  uiwait(msgbox(warningMessage));
else
  fid=fopen(file,'w');
fprintf(fid, text);
fclose(fid);
winopen(file)
msgbox('Text Description is saved in file.');

end



% --- Executes on button press in exit1.
function exit1_Callback(hObject, eventdata, handles)
% hObject    handle to exit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('Thanks for using this app.');
pause(0);
close();
close();
