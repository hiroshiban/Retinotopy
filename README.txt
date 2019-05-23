**********************************************************************
README on the "Retinotopy" stimulus package


Created    : "2013-11-25 10:25:05 ban"
Last Update: "2019-05-23 16:59:33 ban"
**********************************************************************

======================================================================
About Retinotopy stimulus package
======================================================================

This "Retinotopy" stimulus package is a modified version of RetinotopyWithDepth that I once wrote and had used at University of Birmingham, UK, for my ex-fMRI projects.
The current presentation procedures are more accurate in timing, more sophisticated, and more robust against errors.

[system requirements]
- Windows or MacOS
- (preferred) OpenGL-compatible graphic board
- MATLAB 64 bit
- MATLAB Psychtoolbox (and Image Processing Toolbox)

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
 9. cmeridian             : color/luminance-defined dual wedge checkerboards presented along the horizontal or vertical visual meridian with a checker-pattern luminance change detection task
10. cmeridian_fixtask     : color/luminance-defined dual wedge checkerboards presented along the horizontal or vertical visual meridian with a fixation luminance change change detection task
11. chrf                  : color/luminance-defined checkerboard stimuli with a checker-pattern luminance change detection task, for HRF shape estimation
12. chrf_fixtask          : color/luminance-defined checkerboard stimuli with a fixation luminance change detection task, for HRF shape estimation
13. clgnlocalizer         : color/luminance-defined checkerboard stimuli with a checker-pattern luminance change detection task, for localizing LGN
14. clgnlocalizer_fixtask : color/luminance-defined checkerboard stimuli with a fixation luminance change detection task, for localizing LGN
15. clocalizer            : color/luminance-defined checkerboard stimuli with a checker-pattern luminance change detection task, for identifying retinotopic iso-eccentricity subregions
16. clocalizer_fixtask    : color/luminance-defined checkerboard stimuli with a fixation luminance change detection task, for identifying retinotopic iso-eccentricity subregions
17. iretinotopy_fixtask   : object-image-defined retinotopy stimuli with a fixation luminance change detection task, for phase-encoded analysis
18. ibar_fixtask          : object-image-defined bar stimuli with a fixation luminance change detection task, for pRF analysis
19. idual_fixtask         : object-image-defined dual stimuli (polar wedge + eccentricity annulus) with a fixation luminance change detection task, for phase-encoded/pRF analysis
20. imultifocal_fixtask   : object-image-defined multifocal retinotopy stimuli with a fixation luminance change detection task, for GLM or pRF analysis
21. imeridian_fixtask     : object-image-defined dual wedge stimuli presented along the horizontal or vertical visual meridian with a fixation luminance change change detection task
22. ihrf_fixtask          : object-image-defined wedge stimuli with a fixation luminance change detection task, for HRF shape estimation
23. ilgnlocalizer_fixtask : object-image-defined wedge stimuli with a fixation luminance change detection task, for localizing LGN
24. ilocalizer_fixtask    : object-image-defined stimuli with a fixation luminance change detection task, for identifying retinotopic iso-eccentricity subregions
25. dretinotopy           : disparity(depth, Random-Dot-Stereogram (RDS))-defined retinotopy stimuli with a checker-pattern depth change detection task, for phase-encoded analysis
26. dretinotopy_fixtask   : disparity(depth, Random-Dot-Stereogram (RDS))-defined retinotopy stimuli with a fixation luminance change detection task, for phase-encoded analysis
27. dbar                  : disparity(depth, Random-Dot-Stereogram (RDS))-defined bar stimuli with a checker-pattern depth change detection task, for pRF analysis
28. dbar_fixtask          : disparity(depth, Random-Dot-Stereogram (RDS))-defined bar stimuli with a fixation luminance change detection task, for pRF analysis
29. ddual                 : disparity(depth, Random-Dot-Stereogram (RDS))-defined dual stimuli (polar wedge + eccentricity annulus) with a checker-pattern depth change detection task, for phase-encoded/pRF analysis
30. ddual_fixtask         : disparity(depth, Random-Dot-Stereogram (RDS))-defined dual stimuli (polar wedge + eccentricity annulus) with a fixation luminance change detection task, for phase-encoded/pRF analysis
31. dmultifocal           : disparity(depth, Random-Dot-Stereogram (RDS))-defined multifocal retinotopy stimuli with a checker-pattern depth change detection task, for GLM or pRF analysis
32. dmultifocal_fixtask   : disparity(depth, Random-Dot-Stereogram (RDS))-defined multifocal retinotopy stimuli with a fixation luminance change detection task, for GLM or pRF analysis
33. dmeridian             : disparity(depth, Random-Dot-Stereogram (RDS))-defined dual wedge stimuli presented along the horizontal or vertical visual meridian with a checker-pattern depth change detection task
34. dmeridian_fixtask     : disparity(depth, Random-Dot-Stereogram (RDS))-defined dual wedge stimuli presented along the horizontal or vertical visual meridian with a fixation luminance change change detection task
35. dhrf                  : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge stimuli with a checker-pattern depth change detection task, for HRF shape estimation
36. dhrf_fixtask          : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge stimuli with a fixation luminance change detection task, for HRF shape estimation
37. dlgnlocalizer         : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge stimuli with a checker-pattern depth change detection task, for localizing LGN
38. dlgnlocalizer_fixtask : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge stimuli with a fixation luminance change detection task, for localizing LGN
39. dlocalizer            : disparity(depth, Random-Dot-Stereogram (RDS))-defined stimuli with a checker-pattern depth change detection task, for identifying retinotopic iso-eccentricity subregions
40. dlocalizer_fixtask    : disparity(depth, Random-Dot-Stereogram (RDS))-defined stimuli with a fixation luminance change detection task, for identifying retinotopic iso-eccentricity subregions
41. gen_retinotopy_windows: a function for generating checkerboard stimulus windows of ccw/cw/exp/cont, for phase-encoded/pRF analysis
42. gen_bar_windows       : a function for generating standard pRF bar stimulus windows, for pRF analysis
43. gen_dual_windows      : a function for generating checkerboard (wedge + annulus) stimulus windows, for phase-encoded/pRF analysis
44. gen_multifocal_windows: a function for generating multifocal retinoopy checkerboard stimulus windows, for pRF analysis

For more details, please see each function's help.


======================================================================
Examples
======================================================================

>> retinotopy('HB','ccw',1);
>> retinotopy('HB',{'ccw','exp','ccw','exp'},[1,1,2,2]);
>> retinotopy('HB',{'ccwwindows','cwwindows','expwindows','contwindows'},[1,1,1,1]);


======================================================================
Details of retinotopy.m
======================================================================

[input]
exp_mode: experiment mode that you want to run, one of

          *** task -- luminance change detection on the checkerboard
          - ccw     : color/luminance-defined checkerboard wedge rotating counter-clockwisely
          - cw      : color/luminance-defined checkerboard wedge rotating clockwisely
          - exp     : color/luminance-defined checkerboard annulus expanding from fovea to periphery
          - cont    : color/luminance-defined checkerboard annulus contracting from periphery to fovea
          - bar     : color/luminance-defined checkerboard bar, a standard pRF (population receptive field) stimulus
          - ccwexp  : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - ccwcont : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwexp   : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwcont  : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - multifocal : color/luminance-defined checkerboard, a standard multifocal retinotopy stimulus
          - meridian : color/luminance-defined dual wedge checkerboards presented along the horizontal or vertical visual meridian
          - lgn     : color/luminance-defined hemifield checkerboard patterns, 16s rest + 6x(16s left + 16s right) + 16s rest = 240s, to localize LGN
          - hrf     : color/luminance-defined checkerboard pattern, 16s rest + 6x(16s stimulation + 16s rest) + 16s rest = 240s, to evaluate HRF responses
          - localizer : color/luminance-defined checkerboard patterns, 16s rest + 6x(16s stimulation + 16s compensating pattern) + 16s rest = 240s
                      to identify specific iso-eccentricity regions

          *** task -- depth change detection on the checkerboard
          - ccwd    : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge rotating counter-clockwisely
          - cwd     : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge rotating clockwisely
          - expd    : disparity(depth, Random-Dot-Stereogram (RDS))-defined annulus expanding from fovea to periphery
          - contd   : disparity(depth, Random-Dot-Stereogram (RDS))-defined annulus contracting from periphery to fovea
          - bard    : disparity(depth, Random-Dot-Stereogram (RDS))-defined bar, a standard pRF (population receptive field) stimulus
          - ccwexpd : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - ccwcontd  : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwexpd  : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwcontd : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - multifocald  : disparity(depth, Random-Dot-Stereogram (RDS))-defined multifocal retinotopy stimulus
          - meridiand  : disparity(depth, Random-Dot-Stereogram (RDS))-defined dual wedges presented along the horizontal or vertical visual meridian
          - lgnd    : disparity(depth, Random-Dot-Stereogram (RDS))-defined hemifield wedge patterns, 16s rest + 6x(16s left + 16s right) + 16s rest = 240s, to localize LGN
          - hrfd    : disparity(depth, Random-Dot-Stereogram (RDS))-defined pattern, 16s rest + 6x(16s stimulation + 16s rest) + 16s rest = 240s, to evaluate HRF responses
          - localizerd : disparity(depth, Random-Dot-Stereogram (RDS))-defined iso-eccentricity stimulation patterns, 16s rest + 6x(16s stimulation + 16s compensating pattern) + 16s rest = 240s
                       to identify specific iso-eccentricity regions

          *** task -- luminance change detection on the central fixation
          - ccwf    : color/luminance-defined checkerboard wedge rotating counter-clockwisely
          - cwf     : color/luminance-defined checkerboard wedge rotating clockwisely
          - expf    : color/luminance-defined checkerboard annulus expanding from fovea to periphery
          - contf   : color/luminance-defined checkerboard annulus contracting from periphery to fovea
          - barf    : color/luminance-defined checkerboard bar, a standard pRF (population receptive field) stimulus
          - ccwexpf : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - ccwcontf: color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwexpf  : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwcontf : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - multifocalf : color/luminance-defined checkerboard, a standard multifocal retinotopy stimulus
          - meridianf : color/luminance-defined dual wedge checkerboards presented along the horizontal or vertical visual meridian
          - lgnf    : color/luminance-defined hemifield checkerboard patterns, 16s rest + 6x(16s left + 16s right) + 16s rest = 240s, to localize LGN
          - hrff    : color/luminance-defined checkerboard pattern, 16s rest + 6x(16s stimulation + 16s rest) + 16s rest = 240s, to evaluate HRF responses
          - localizerf : color/luminance-defined checkerboard patterns, 16s rest + 6x(16s stimulation + 16s compensating pattern) + 16s rest = 240s
                       to identify specific iso-eccentricity regions

          - ccwi    : Object-image-defined wedge rotating counter-clockwisely
          - cwi     : Object-image-defined wedge rotating clockwisely
          - expi    : Object-image-defined annulus expanding from fovea to periphery
          - conti   : Object-image-defined annulus contracting from periphery to fovea
          - bari    : Object-image-defined bar, a standard pRF (population receptive field) stimulus
          - ccwexpi : Object-image-defined wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - ccwconti: Object-image-defined wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwexpi  : Object-image-defined wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwconti : Object-image-defined wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - multifocali : Object-image-defined multifocal retinotopy stimulus
          - meridiani : Object-image-defined dual wedges presented along the horizontal or vertical visual meridian
          - lgni    : Object-image-defined hemifield wedge patterns, 16s rest + 6x(16s left + 16s right) + 16s rest = 240s, to localize LGN
          - hrfi    : Object-image-defined pattern, 16s rest + 6x(16s stimulation + 16s rest) + 16s rest = 240s, to evaluate HRF responses
          - localizeri: Object-image-defined iso-eccentricity stimulation patterns, 16s rest + 6x(16s stimulation + 16s compensating pattern) + 16s rest = 240s
                      to identify specific iso-eccentricity regions

          - ccwdf   : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge rotating counter-clockwisely
          - cwdf    : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge rotating clockwisely
          - expdf   : disparity(depth, Random-Dot-Stereogram (RDS))-defined annulus expanding from fovea to periphery
          - contdf  : disparity(depth, Random-Dot-Stereogram (RDS))-defined annulus contracting from periphery to fovea
          - bardf   : disparity(depth, Random-Dot-Stereogram (RDS))-defined bar, a standard pRF (population receptive field) stimulus
          - ccwexpdf: disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - ccwcontdf : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwexpdf : disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - cwcontdf: disparity(depth, Random-Dot-Stereogram (RDS))-defined wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
          - multifocaldf : disparity(depth, Random-Dot-Stereogram (RDS))-defined multifocal retinotopy stimulus
          - meridiandf : disparity(depth, Random-Dot-Stereogram (RDS))-defined dual wedges presented along the horizontal or vertical visual meridian
          - lgndf   : disparity(depth, Random-Dot-Stereogram (RDS))-defined hemifield wedge patterns, 16s rest + 6x(16s left + 16s right) + 16s rest = 240s, to localize LGN
          - hrfdf   : disparity(depth, Random-Dot-Stereogram (RDS))-defined pattern, 16s rest + 6x(16s stimulation + 16s rest) + 16s rest = 240s, to evaluate HRF responses
          - localizerdf: disparity(depth, Random-Dot-Stereogram (RDS))-defined iso-eccentricity stimulation patterns, 16s rest + 6x(16s stimulation + 16s compensating pattern) + 16s rest = 240s
                       to identify specific iso-eccentricity regions

          *** these are stimulus windows to generate pRF (population receptive field) model
          - ccwwindows     : stimulation windows of wedge rotating counter-clockwisely
          - cwwindows      : stimulation windows of wedge rotating clockwisely
          - expwindows     : stimulation windows of annulus expanding from fovea
          - contwindows    : stimulation windows of annulus contracting from periphery
          - barwindows     : stimulation windows of a standard pRF bar
          - ccwexpwindows  : stimulation windows of a wedge+annulus checkerboard pattern
          - ccwcontwindows : stimulation windows of a wedge+annulus checkerboard pattern
          - cwexpwindows   : stimulation windows of a wedge+annulus checkerboard pattern
          - cwcontwindows  : stimulation windows of a wedge+annulus checkerboard pattern
          - multifocalwindows : stimulation windows of a standard multifocal retinotopy stimulus

          a string or a cell string structure, e.g. 'ccw', or {'ccw','exp'}
          length(exp_mode) should equal numel(acq_num)
acq_num : acquisition number, 1,2,3,...

=== NOTE: the two input variables below are only effective when exp_mode is set to *windows (one of stimulus window generation functions) ===
overwrite_pix_per_deg : (optional) pixels-per-deg value to overwrite the sparam.pix_per_deg
          if not specified, sparam.pix_per_deg is used to reconstruct
          stim_windows.
          This is useful to reconstruct stim_windows with less memory space
          1/pix_per_deg = spatial resolution of the generated visual field,
          e.g. when pix_per_deg=20, then, 1 pixel = 0.05 deg.
          empty (use sparam.pix_per_deg) by default
TR      : (optional) TR used in fMRI scans, in sec, 2 by default

[output]
OK      : (optional) flag, whether this script finished without any error [true/false]


For more details, please see the comment lines of retinotopy.m


======================================================================
About the object image databases used in the Retinotopy package
======================================================================

The object images stored in the object_image_database.mat and used in i* retinotopy stimuli are obtained and modified from the databases publicly available from
http://konklab.fas.harvard.edu/#
I sincerely express my gratitude to the developers and distributors, scientists in Dr Talia Konkle's research group, for their contributions in these databases.

[Original papers of these image datasets]
- Tripartite Organization of the Ventral Stream by Animacy and Object Size.
  Konkle, T., & Caramazza, A. (2013). Journal of Neuroscience, 33 (25), 10235-42.

- A real-world size organization of object responses in occipito-temporal cortex.
  Konkle. T., & Oliva, A. (2012). Neuron, 74(6), 1114-24.

- Visual long-term memory has a massive storage capacity for object details.
  Brady, T. F., Konkle, T., Alvarez, G. A. & Oliva, A. (2008). Proceedings of the National Academy of Sciences USA, 105(38), 14325-9.

- Conceptual distinctiveness supports detailed visual long-term memory.
  Konkle, T., Brady, T. F., Alvarez, G. A., & Oliva, A. (2010). Journal of Experimental Psychology: General, 139(3), 558-578.

- A Familiar Size Stroop Effect: Real-world size is an automatic property of object representation.
  Konkle, T., & Oliva, A. (2012). Journal of Experimental Psychology: Human Perception & Performance, 38, 561-9.


======================================================================
TODOs
======================================================================

1. Update the procedure for getting response more precisely.
2. *DONE* Generate dretinotopy (3D depth version of the retinotopy stimuli) in which checkerboards consist of Random-Dot-Stereograms
