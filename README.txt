***********************************
README for "Retinotopy" stimulus package

Created    : "2013-11-25 10:25:05 ban"
Last Update: "2019-02-01 19:06:58 ban"
***********************************

[about Retinotopy package]
This "Retinotopy" experiment package is a modified version of RetinotopyWithDepth
that I once wrote and had used at University of Birmingham, UK, for my ex-fMRI projects.
The current presentation procedures are more sophisticated, robust to errors, and
more suitable with settings of fMRI experiments at CiNet, Osaka, Japan.

[about the scripts]
Please go to ~/Retinotopy/Presentation/ and you will find a function, named retinotopy.m

The "retinotopy.m" function is a simple wrapper to control phase-encoded/pRF retinotopy stimuli.
The fMRI responses evoked by the stimuli can be used to delineate borders of retinotopic visual areas.

The wrapped functions are as below.
    1. cretinotopy           : color/luminance-defined checkerboard stimuli with a checker-pattern luminance change detection task, for phase-encoded analysis
    2. cretinotopy_fixtask   : color/luminance-defined checkerboard stimuli with a fixation luminance change detection task, for phase-encoded analysis
    3. cbar                  : color/luminance-defined checkerboard bar stimuli with a checker-pattern luminance change detection task, for pRF analysis
    4. cbar_fixtask          : color/luminance-defined checkerboard bar stimuli with a fixation luminance change detection task, for pRF analysis
    5. cdual                 : color/luminance-defined checkerboard stimuli (polar wedge + eccentricity annulus) with a checker-pattern luminance change detection task, for phase-encoded/pRF analysis
    6. cdual_fixtask         : color/luminance-defined checkerboard stimuli (polar wedge + eccentricity annulus) with a fixation luminance change detection task, for phase-encoded/pRF analysis
    7. cmultifocal           : color/luminance-defined multifocal retinotopy checkerboard stimuli with a checker-pattern luminance change detection task, for GLM or pRF analysis
    8. cmultifocal_fixtask   : color/luminance-defined multifocal retinotopy checkerboard stimuli with a fixation luminance change detection task, for GLM or pRF analysis
    9. cmeridian             : color/luminance-defined dual wedge checkerboard stimuli presented along the horizontal or vertical visual meridian with a checker-pattern luminance change detection task
   10. cmeridian_fixtask     : color/luminance-defined dual wedge checkerboard stimuli presented along the horizontal or vertical visual meridian with a fixation luminance change change detection task
   11. chrf                  : color/luminance-defined checkerboard stimuli with a checker-pattern luminance change detection task, for HRF shape estimation
   12. chrf_fixtask          : color/luminance-defined checkerboard stimuli with a fixation luminance change detection task, for HRF shape estimation
   13. clgnlocalizer         : color/luminance-defined checkerboard stimuli with a checker-pattern luminance change detection task, for localizing LGN
   14. clgnlocalizer_fixtask : color/luminance-defined checkerboard stimuli with a fixation luminance change detection task, for localizing LGN
   15. clocalizer            : color/luminance-defined checkerboard stimuli with a checker-pattern luminance change detection task, for identify retinotopic subregions
   16. clocalizer_fixtask    : color/luminance-defined checkerboard stimuli with a fixation luminance change detection task, for identify retinotopic subregions
   17. gen_retinotopy_windows: a function for generating checkerboard stimulus windows of ccw/cw/exp/cont, for phase-encoded/pRF analysis
   18. gen_bar_windows       : a function for generating standard pRF bar stimulus windows, for pRF analysis
   19. gen_dual_windows      : a function for generating checkerboard (wedge + annulus) stimulus windows, for phase-encoded/pRF analysis
   20. gen_multifocal_windows: a function for generating multifocal retinoopy checkerboard stimulus windows, for pRF analysis
For details, see each function's help.

[example]
>> retinotopy('HB','ccw',1);
>> retinotopy('HB',{'ccw','exp','ccw','exp'},[1,1,2,2]);
>> retinotopy('HB',{'ccwwindows','cwwindows','expwindows','contwindows'},[1,1,1,1]);

[input]
subj    : subject's name, e.g. 'HB'
exp_mode: experiment mode that you want to run, one of

          *** task -- luminance change detection on the checkerboard
          - ccw     : color/luminance-defined checkerboard wedge rotated counter-clockwisely
          - cw      : color/luminance-defined checkerboard wedge rotated clockwisely
          - exp     : color/luminance-defined checkerboard anuulus expanding from fovea
          - cont    : color/luminance-defined checkerboard annulus contracting from periphery
          - bar     : color/luminance-defined checkerboard bar, a standard pRF (population receptive field) stimulus
          - ccwexp  : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - ccwcont : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwexp   : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwcont  : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - multifocal : color/luminance-defined checkerboard for a standard multifocal retinotopy stimulus
          - meridian : color/luminance-defined dual wedge checkerboard presented along the horizontal or vertical visual meridian
          - lgn     : color/luminance-defined checkerboard hemifield wedge pattern 16s rest + 6x(16s left + 16s right) + 16s rest = 240s
                      to localize LGN
          - hrf     : color/luminance-defined checkerboard pattern 16s rest + 6x(16s stimulation + 16s rest) + 16s rest = 240s
                      to measure HRF responses and to test scanner sequence
          - localizer : color/luminance-defined checkerboard pattern 16s rest + 6x(16s stimulation + 16s compensating pattern) + 16s rest = 240s
                      to identify specific eccentricity corresponding regions

          *** task -- luminance change detection on the central fixation
          - ccwf    : color/luminance-defined checkerboard wedge rotated counter-clockwisely
          - cwf     : color/luminance-defined checkerboard wedge rotated clockwisely
          - expf    : color/luminance-defined checkerboard anuulus expanding from fovea
          - contf   : color/luminance-defined checkerboard annulus contracting from periphery
          - barf    : color/luminance-defined checkerboard bar, a standard pRF (population receptive field) stimulus
          - ccwexpf : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - ccwcontf: color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwexpf  : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwcontf : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - multifocalf : color/luminance-defined checkerboard for a standard multifocal retinotopy stimulus
          - meridianf : color/luminance-defined dual wedge checkerboard presented along the horizontal or vertical visual meridian
          - lgnf    : color/luminance-defined checkerboard hemifield wedge pattern 16s rest + 6x(16s left + 16s right) + 16s rest = 240s
                      to localize LGN
          - hrff    : color/luminance-defined checkerboard pattern 16s rest + 6x(16s stimulation + 16s rest) + 16s rest = 240s
                      to measure HRF responses and to test scanner sequence
          - localizerf: color/luminance-defined checkerboard pattern 16s rest + 6x(16s stimulation + 16s compensating pattern) + 16s rest = 240s
                      to identify specific eccentricity corresponding regions

          *** these are stimulus windows to generate pRF (population receptive field) model
          - ccwwindows     : stimulation windows of wedge rotated counter-clockwisely
          - cwwindows      : stimulation windows of wedge rotated clockwisely
          - expwindows     : stimulation windows of annulus expanding from fovea
          - contwindows    : stimulation windows of annulus contracting from periphery
          - barwindows     : stimulation windows of a standard pRF bar
          - ccwexpwindows  : stimulation windows of a wedge+annulus checkerboard pattern
          - ccwcontwindows : stimulation windows of a wedge+annulus checkerboard pattern
          - cwexpwindows   : stimulation windows of a wedge+annulus checkerboard pattern
          - cwcontwindows  : stimulation windows of a wedge+annulus checkerboard pattern
          - multifocalwindows : stimulation windows of a standard multifocal retinotopy stimulus

          string or a cell string structure, e.g. 'ccw', or {'ccw','exp'}
          length(exp_mode) should equal numel(acq_num)
acq_num : acquisition number, 1,2,3,...


For more details, please see the comment lines of retinotopy.m
