muscle_set = {'add_brev', 'add_long', 'add_mag1', 'psoas', 'glut_max1', ...
    'bifemlh', 'rect_fem', 'vas_med', 'med_gas', 'soleus'};
label_set = {'Add. brev.', 'Add. long.', 'Add. mag.', 'Psoas', ...
    'Glut. max.', 'Bifemlh', 'Rect. fem.', 'Vas. med.', 'Med. gas.', ...
    'Soleus'};
save_set = {'add-brev', 'add-long', 'add-mag', 'psoas', 'glut-max', ...
    'bifemlh', 'rect-fem', 'vas-med', 'med-gas', 'soleus'};

for i=1:length(muscle_set)
    figure;
    Metrics.(muscle_set{i}).plot3DBar('relative_signed');
    saveas(gcf, ['F:\Dropbox\Apps\TeX Writer\Frontiers Paper Redraft' filesep save_set{i} '.png']);
end