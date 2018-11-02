This program has been created based on a program from James Crall (https://github.com/jamescrall/idBEE/) in which we added few functions.

If you only want to track tags, please use the original code from James Crall : https://github.com/jamescrall/idBEE/

If you want more info and explanation, please read the pdf document : 
1) Protocol: tracking an animal in a long period divided into sessions 
2) Protocol: finding the best parameters


REQUIREMENTS

- Matlab (tested with 2013b, 2014b, 2016b, 2017b, 2018b) with Image Processing Toolbox

INSTALLATION
1. Download all functions and files from available on github from https://github.com/mathjoss/BEETag_for_chicks.git
 and add to matlab path (making sure to "Add with
Subfolders")

2. Run trackingExample.m to check functionality



INSTRUCTIONS FOR OPERATION

1. Read more info from https://github.com/jamescrall/idBEE/ if you want to understand more about LocateCodes, and all functions originally created by James Crall.

2. Write inside an excel file (same format as the excel file sessions_matlab.xlsx) the first 8 columns information, and add videos to a folder

3. Run transform_xls_txt_file

4. Run tracking_coordinator


FILES EXPLANATION

1. addcolumntxtfile : add a column into your txt files without running the script trasnform_xls_txt_files again.

2. createbigvideo : create a video mixing different frames from different video

3. find_location : find the number of seconds spent in a certain area

4. find_orientation : find the number of seconds spent in different body orientation

5. manually_test_accuracy_step1 : create a txt file stored in test_accuracy with random frames analysed

6. manually_test_accuracy_step2 : use the txt files created in step1, ask user input for orientation in all random frames selected previously and compare the results : user input /vs/ Beetag

7. naninterp : interpolate values from a vector

8. optimizeTrackingParameters : optimize the tracking parameters on a video (from Claire Guerin)

9. transform_xls_txt_files : create txt files out of a excel sheet for all chicks

10. tracking_coordinator : main file coordinating all functions

11. tracking_coordinator_test : same as tracking_coordinator but used for short video (generates only 1 row of output)


** Excel document : example of how data should be written in order to run the script transform_xls_txt_files


** Folders :
- txtfiles_chicks : contains all txt files needed to run tracking_coordinator
- test_accuracy : contains output of manually_test_accuracy_step1 


CONTACT mathilde.josserand@gmail.com or bastien.lemaire@unitn.it with any questions
