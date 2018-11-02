************  
Files explanation 

************



** Functions specific to Beetag_for_chicks :

- addcolumntxtfile : allow you to add a column into your txt files without running the script trasnform_xls_txt_files again.

- createbigvideo : allow you to create a video mixing different frames from different video

- find_location : find the number of seconds spent in a certain area

- find_orientation : find the number of seconds spent in different body orientation

- manually_test_accuracy_step1 : generate a txt file stored in test_accuracy with random frames analysed

- manually_test_accuracy_step2 : after you did step1, use the txt files created before, ask user input for orientation in all frames and compare the results : user input // Beetag

- naninterp : interpolate values from a vector

- optimizeTrackingParameters : optimize the tracking parameters on a video

- transform_xls_txt_files : out of a excel sheet, will create txt files for all chicks

- tracking_coordinator : main file coordinating all functions

- tracking_coordinator_test : same as tracking_coordinator but used for short video (generates only 1 row of output)



 ** Functions coming from Beetag (James Crall and al), read README for more info

- create1000PrintableTags 

- createRobustListTags

- createSinglePrintableTag

- locateCodes

- trackingExample 
 
- trackBEEtagsAcrossFrames : step between tracking_coordinator and LocateCodes (not really useful in our experiment)




** Pictures : for trackingExample


** Excel document : example of how data should be written in order to run the script transform_xls_txt_files


** Folders :
- txtfiles_chicks : contains all txt files needed to run tracking_coordinator
- test_accuracy : contains output of manually_test_accuracy_step1 
