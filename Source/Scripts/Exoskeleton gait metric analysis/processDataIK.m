% Create cell arrays to hold the results.
% First index is the subject identifier, from 1-9 technically but not
% including 5 because we didn't get full data for this, but I'll still go from
% 1-9 since these are their subject numbers. 
% Second index is the type of assistance: 1 for no exo (NE), 2 for transparent
% (ET) and 3 for active (EA).
% Second index is left/right gait cycle. 1 for right, 2 for left.
% Third index is the number of gait cycles among the trials. (EA1, EA2
% etc). These are in the same order as they were recorded. So EA1 is
% nonstst, EA2 stst, etc.
IK_array{9,3,2,10} = {};
Input_Markers_array{9,3,2,10} = {};
Output_Markers_array{9,3,2,10} = {};

% Get the root folder. 
root = ['C:\Users\Daniel\University of Edinburgh\OneDrive - University '...
    'of Edinburgh\Exoskeleton metrics data\Data files\'];

% Total number of IK's to perform. 
% 8 subjects. 2 leading foot types. 3 exoskeleton assistance mode.
% 5 contexts associated with 2 gait cycles, another 5 contexts associated
% with 5 gait cycles.
% 8*2*3*(5*2 + 5*5)
total_iks = 1680;

% IK's performed so far. 
current_ik = 0;

% Construct a loading bar. 
loadbar = waitbar(current_ik, 'Performing batch IK.');

% Loop over the nine subjects. 
for subject=1:8
    % Skip the missing data. 
    if ~ (subject == 5)
        % There are four dates which need to be represented in the path.
        if subject == 1 || subject == 3 || subject == 4
            date = '18';
        elseif subject == 2
            date = '16';
        elseif subject == 6
            date = '19';
        else
            date = '22';
        end
        
        % Get the path for this subject. 
        subject_path = [root 'S' num2str(subject) '\17-05-' date];

        % Get the path for the scaled APO and no-APO models for this subject.
        human_model = [subject_path '\Scaling\no_APO.osim'];
        APO_model = [subject_path '\Scaling\APO.osim'];

        % Loop over left/right gait cycles. 
        for j=1:2
            switch j
                case 1
                    gait = [subject_path '\dynamicElaborations\right'];
                case 2
                    gait = [subject_path '\dynamicElaborations\left'];
            end
            
            % Loop over the ten contexts. 
            for i=1:10  
                % Filenames are different for steady state vs non steady state.
                if mod(i,2) == 1
                    folder = [gait 'Non-StSt'];
                else
                    folder = [gait 'StSt'];
                end
                
                for assistance_level=1:3
                    if assistance_level == 1
                        % No APO.
                        ik_folder = [folder '\NE' num2str(i)];
                        model = human_model;
                    elseif assistance_level == 2
                        % With APO, transparent.
                        ik_folder = [folder '\ET' num2str(i)];
                        model = APO_model;
                    elseif assistance_level == 3
                        % With APO, assisted. 
                        ik_folder = [folder '\EA' num2str(i)];
                        model = APO_model;
                    end
                    [IK_array{subject,assistance_level,j,i}, ...
                    Input_Markers_array{subject,assistance_level,j,i},...
                    Output_Markers_array{subject,assistance_level,j,i}] ...
                        = runBatchIK(model, ik_folder, [ik_folder '\IK_Results']);
                    if mod(i,2) == 1
                        current_ik = current_ik + 2;
                    else
                        current_ik = current_ik + 5;
                    end
                    waitbar(current_ik/total_iks);
                end
            end
        end
    end
end

% Close the loading bar.
close(loadbar);

% Save the results to a Matlab save file.
save([root 'IK_Results.mat'], 'IK_array', 'Input_Markers_array', ... 
    'Output_Markers_array');
