function result = initialiseSubjectData(subject)

weights = [76.4 67.1 58.8 77.2 132 83 61.4 66.6 75.8];
leg_lengths = [0.93 0.93 0.91 0.9 0.97 0.97 0.94 0.95 0.92];

% Note the reason for the rows of 0's - constant walking speed is only a
% thing at the steady state contexts!
walking_speeds = [0 0 0 0 0 0 0 0;...
    0.95 0.95 0.94 0.94 0.98 0.98 0.96 0.97;...
    0 0 0 0 0 0 0 0;...
    0.95 0.95 0.94 0.94 0.98 0.98 0.96 0.97;...
    0 0 0 0 0 0 0 0;...
    0.95 0.95 0.94 0.94 0.98 0.98 0.96 0.97;...
    0 0 0 0 0 0 0 0;...
    1.14 1.14 1.13 1.13 1.18 1.18 1.15 1.16;...
    0 0 0 0 0 0 0 0;...
    0.76 0.76 0.75 0.75 0.78 0.78 0.77 0.78];

result.Name = ['subject' num2str(subject)];
result.Properties.LegLength = leg_lengths(subject);
result.Properties.WalkingSpeed = walking_speeds(1:end,subject);
result.Properties.Weight = weights(subject);
end

