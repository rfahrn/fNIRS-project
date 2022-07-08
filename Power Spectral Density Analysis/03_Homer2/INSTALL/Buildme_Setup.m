function Buildme_Setup(dirname)

dirnameInstall = pwd;
cd(dirname);

inclList = {...
    '../PACKAGES/AtlasViewerGUI/ForwardModel' ...
};
Buildme('setup', inclList, {}, {'-e'});

cd(dirnameInstall);

