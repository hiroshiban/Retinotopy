***********************************
README for retinotopy stimuli

Created    : "2013-11-25 10:25:05 ban (ban.hiroshi@gmail.com)"
Last Update: "2013-11-26 10:55:33 ban (ban.hiroshi@gmail.com)"
***********************************

[about Retinotopy package]
This "Retinotopy" experiment package is a modified version of RetinotopyWithDepth
that I once wrote and had used at University of Birmingham, UK, for my ex-fMRI projects.
The current presentation procedures are more sophisticated, robust to errors, and
more suitable with settings of fMRI experiments at CiNet, Osaka, Japan.

[about the scripts]
- Please go to ~/Retinotopy/Presentation/. You will find all the core functions there. The details are as below.
1. retinotopy             : a simple wrapper to run cretinotopy or dretinotopy.
2. cretinotopy            : checkerboard patterns, luminance detection task at one of the checker patch.
3. cretinotopy_fixtask    : checkerboard patterns, luminance detection task at the central fixation.
4. chrf_fixtask           : checkerboard patterns to measure HRF response function, checker vs rest, block-design.
5. gen_retinotopy_windows : generate stimulation windows for population-receptive-field analyses.

[how to use]
- You can present all types of retinotopy stimuli through a simple wrapper script, retinotopy.m.

- For example, you can run "ccw" stimulus protocol by typing
  >> retinotopy('HB','checkerccw',1);

- The usage of the retinotopy wrapper script is as below.

>> retinotopy(subj,exp_mode,acq_num);

subj    : subject's name, e.g. 'HB'
exp_mode: experiment mode that you want to run, one of
          (task -- luminance change detection on the checkerboard for 4 modes below)
          - checkerccw   : color/luminance-defined checkerboard wedge rotated counter-clockwisely
          - checkercw    : color/luminance-defined checkerboard wedge rotated clockwisely
          - checkerexp   : color/luminance-defined checkerboard anuulus expanding from fovea
          - checkercont  : color/luminance-defined checkerboard annulus contracting from periphery
          (task -- luminance change detection on the central fixation for 4 modes below)
          - checkerccwf  : color/luminance-defined checkerboard wedge rotated counter-clockwisely
          - checkercwf   : color/luminance-defined checkerboard wedge rotated clockwisely
          - checkerexpf  : color/luminance-defined checkerboard anuulus expanding from fovea
          - checkercontf : color/luminance-defined checkerboard annulus contracting from periphery
          (task -- luminance change detection on the central fixation for 4 modes below)
          - hrf          : color/luminance-defined checkerboard pattern 16s rest + 6x(16s stimulation + 16s rest) + 16s rest = 240s
                           to measure HRF responses and to test scanner sequence
          (these are stimulus windows to generate pRF (population receptive field) model)
          - ccwwindows   : stimulation windows of wedge rotated counter-clockwisely
          - cwwindows    : stimulation windows of wedge rotated clockwisely
          - expwindows   : stimulation windows of annulus expanding from fovea
          - contwindows  : stimulation windows of annulus contracting from periphery
          string, or cell string structure, e.g. 'checkerccw', or {'checkerccw','checkerexp'}
          length(exp_mode) should equal numel(acq_num)
acq_num : acquisition number, 1,2,3,...

For more details, please see the comment lines of retinotopy.m
