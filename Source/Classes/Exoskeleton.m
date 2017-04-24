classdef Exoskeleton 
    % Class to hold all the files, settings and paramters which are
    % exoskeleton specific. For example, the model file, controller
    % parameters like link lengths. The contact point settings file. 
    
    properties (SetAccess = private)
        Name
        Model % Human/exoskeleton OpenSim model 
        ContactPoints % Contact points settings file (Jacobians). 
        ExternalLoads % External loads settings files (forward simulation).
    end
    
    methods
        
        function obj = Exoskeleton(name, varargin)
            if nargin > 0
                obj.Name = name;
            end
            if size(varargin,2) == 0
                obj = obj.loadDefaults();
            elseif size(varargin,2) ~= 3
                error('Exoskeleton class accepts 1 or 4 arguments only.')
            else
                obj.Model = varargin{1,1};
                obj.ContactPoints = varargin{1,2};
                obj.ExternalLoads = varargin{1,3};
            end
        end
        
        function model = constructExoskeletonForceModel(obj, states, dir, desc)
            % Desc is a description of the force model to be calculated.
            % E.g. 'linear', for the linearAPOForceModel.
            if strcmp(obj.Name, 'APO')
                if strcmp(desc, 'old_linear')
                    model = obj.constructOldLinearAPOForceModel(states, dir);
                elseif strcmp(desc, 'linear')
                    model = obj.constructLinearAPOForceModel(states, dir);
                else 
                    error('Force model not recognised.');
                end
            else
                error('Exoskeleton has no force models!')
            end
        end
        
        function obj = loadDefaults(obj)
            % Search for the appropriate files in the default folder(s). 
            obj.Model = [getenv('EXOPT_HOME') '/Defaults/Model/' ...
                obj.Name '.osim'];
            obj.ContactPoints = [getenv('EXOPT_HOME') ...
                '/Defaults/ContactPointSettings/' obj.Name '.xml'];
            obj.ExternalLoads = [getenv('EXOPT_HOME') ...
                '/Defaults/ExternalLoads/' obj.Name '.xml'];
            
            % If these files don't exist, throw an error. 
            if exist(obj.Model, 'file') ~= 2 
                error('Could not find default model for given exoskeleton.');
            elseif exist(obj.ContactPoints, 'file') ~= 2
                error('Could not find default contacts for given exoskeleton.');
            elseif exist(obj.ExternalLoads, 'file') ~= 2
                error('Could not find default ext. for given exoskeleton.');
            end
        end
        
        function name = getName(obj)
            name = obj.Name;
        end
        
        function model_path = getModel(obj)
            model_path = obj.Model;
        end
        
        function contact_settings = getContactSettings(obj)
            contact_settings = obj.ContactPoints;
        end
        
        function external_loads = getExternalLoads(obj)
            external_loads = obj.ExternalLoads;
        end
        
    end
    
    methods (Access = private)
        
        % Private since only want constructExoskeletonFroceModel to be able
        % to use this.
        function APO_model = constructOldLinearAPOForceModel(obj, states, dir)
            % Inputs are states & a directory for results to be stored. 
            
            % Hard coded APO link length for now. But in the future this
            % should be interpreted from the ContactPointSettings file.
            d = 0.35;
            
            Jacobians = FrameJacobianSet(obj.Model, states, ...
                obj.getContactSettings(), dir);
            
            nTimesteps = size(states.Timesteps,1);
            Q = 0;
            P{nTimesteps} = 0;
            
            % Get the left & right hip flexion joint angles in vector form.
            right_hip_flexion = states.getDataCorrespondingToLabel(...
                'hip_flexion_r');
            left_hip_flexion = states.getDataCorrespondingToLabel(...
                'hip_flexion_l');
            
            for i=1:nTimesteps
                unit_right_force = [0;0;0; ...
                    cos(right_hip_flexion(i,1));sin(right_hip_flexion(i,1));0];
                unit_left_force = [0;0;0; ...
                    cos(left_hip_flexion(i,1));sin(left_hip_flexion(i,1));0];
                right_jacobian = Jacobians.JacobianSet{1}.Jacobian.Values{i};
                left_jacobian = Jacobians.JacobianSet{2}.Jacobian.Values{i};
                P{i} = 1/d*[right_jacobian.' * unit_right_force ...
                    , left_jacobian.' * unit_left_force];
            end
            APO_model = LinearExoskeletonForceModel(obj, states, P, Q);
            
        end
        
        % This will be for the new APO model with 2 additional contact
        % points. But first I want to compare that I get the same results
        % as last time using the old model as a validation step. 
        function APO_model = constructLinearAPOForceModel(obj, states, dir)
        end
        
    end
    
end

