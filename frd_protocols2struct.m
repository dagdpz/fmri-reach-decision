%% Importing MRI protocols from csv into struct

uiopen('C:\Users\pneumann\Downloads\protocols - Tabellenblatt1.csv',1)

%%

sub = protocolsTabellenblatt1;

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
    temp_p = sub(strcmp(part_uni(p),sub.participant),:); % take all data from one subject
    
    sesh_uni = unique(temp_p.session)
    
    
    

end
