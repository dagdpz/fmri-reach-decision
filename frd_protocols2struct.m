function prot = frd_protocols2struct(runpathwithfilename)

%  Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_exp.csv

% when importing via ui: only session and scannernr1/-2 are numbers, the
% rest is text AND replace missing with NaN --> in table

if nargin < 1
    runpathwithfilename = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_exp.csv';
end



%%

sub = importfile(runpathwithfilename);

prot = struct();

%% file up empty rows with stuff

for i = 1:height(sub)
   
    if ~strcmp('',sub.participant(i)) 
        part = sub.participant(i);
    end
    
    if ~isnan(sub.session(i))
        sesh = sub.session(i);
        sesh_date = sub.session_date(i);
        hum_number = sub.hum_nummer(i);
    end
    
    sub.participant(i) = part;
    sub.session(i) = sesh;
    sub.session_date(i) = sesh_date;
    sub.hum_nummer(i) = hum_number;
    
end
%%

part_uni = unique(sub.participant);


%%

for p = 1:length(part_uni)
    
    % take all data from one subject
    temp_p = sub(strcmp(part_uni(p),sub.participant),:); 

    sesh_uni = unique(temp_p.session);
    
    for s = 1:length(sesh_uni) % go through all sessions of respective participant
        
        temp_p_s = temp_p(temp_p.session == sesh_uni(s), : );
        
        prot(p).name = part_uni(p);
        prot(p).session(s).date = temp_p_s.session_date(1);
        prot(p).session(s).hum = temp_p_s.hum_nummer(1);
        
        
        e = 1;
        t = 1;
        for r = 1:length(temp_p_s.sequence)

            if strcmp('EPI',temp_p_s.sequence(r)) % add EPI data
                
                prot(p).session(s).epi(e).nr1 = temp_p_s.scannernr1(r); 
                prot(p).session(s).epi(e).nr2 = temp_p_s.scannernr2(r);
                prot(p).session(s).epi(e).mat_file = [char(temp_p_s.matfile_beginning(r)) char(temp_p_s.matfile_end(r)) '.mat'];
                prot(p).session(s).epi(e).mat_number = str2double(temp_p_s.matfile_end(r));
%               
                e = e + 1;
                
            elseif strcmp('T1',temp_p_s.sequence(r)) % T1 
                prot(p).session(s).T1.nr1 = temp_p_s.scannernr1(r);
                prot(p).session(s).T1.nr2 = temp_p_s.scannernr2(r);
            
            elseif strcmp('topup',temp_p_s.sequence(r))
                prot(p).session(s).topup(t).nr1 = temp_p_s.scannernr1(r);
                
                t = t + 1;
                
            elseif strcmp('abort*',temp_p_s.sequence(r))
                prot(p).session(s).abort = 'Have a look again in protocol. I am too lazy to program that now.';
               
            end
            
            
        end % loop sequences
    end % loop sessions
end % loop participants


save('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_exp.mat','prot');



function protocolsTabellenblatt1 = importfile(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as a matrix.
%   PROTOCOLSTABELLENBLATT1 = IMPORTFILE(FILENAME) Reads data from text
%   file FILENAME for the default selection.
%
%   PROTOCOLSTABELLENBLATT1 = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads
%   data from rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   protocolsTabellenblatt1 = importfile('protocols - Tabellenblatt1.csv',
%   2, 182);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2020/01/30 14:26:38

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Format string for each line of text:
%   column1: text (%s)
%	column2: double (%f)
%   column3: text (%s)
%	column4: text (%s)
%   column5: double (%f)
%	column6: double (%f)
%   column7: text (%s)
%	column8: text (%s)
%   column9: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%f%s%s%f%f%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
protocolsTabellenblatt1 = table(dataArray{1:end-1}, 'VariableNames', {'participant','session','session_date','hum_nummer','scannernr1','scannernr2','sequence','matfile_beginning','matfile_end'});

