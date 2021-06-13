Image processing via MAT LAB
clc
clear all
warning off
imaqreset
ser1 = serial('COM3');
load('reg_face.mat')
st_menu = 'y';
tts('Welcome to Credit Card system using Face Recognition.')
vidobj = videoinput('winvideo',1,'YUY2_320x240');    
set(vidobj,'ReturnedColorSpace','RGB');   % setting the properties of object
set(vidobj,'FramesPerTrigger',1);       
set(vidobj,'TriggerRepeat',inf);        
triggerconfig(vidobj,'manual');  
videoRes = get(vidobj, 'VideoResolution');
numberOfBands = get(vidobj, 'NumberOfBands');
% handleToImage = image( zeros([videoRes(2), videoRes(1), numberOfBands], 'uint8') );
start(vidobj);
% axes(handles.axes2);
% preview(vidobj)
TrainDatabasePath = strcat(pwd,'\register');
while st_menu == 'y'
N = menu('Credit Card reader using Face Recognition','Register','Payment','Refill','Reset','Cancel');
if (N == 1)
    clc;
    tts('Kindly enter your name')
    r_name = input('Enter your name: ','s');
    r_name = lower(r_name);
    
    if r_count == 0
%        r_count = r_count + 1;
%        face_db{r_count,1} = r_name;
%        face_db{r_count,2} = 1;
       r_entry = 0;
    else
        for i=1:r_count
        if (strcmp(r_name,face_db{i,1}))
            r_entry = 1;
            r_count1 = i;
            break
        else
            r_entry = 0;
end
        end
    end
    
    if (r_entry == 0)
        tts('Enter your 10 digit mobile number.')
        r_no = input('Enter your 10 digit mobile number: ','s');
        r_no = lower(r_no);
        disp('Kindly show your RFID card');
        tts('Kindly show your RFID card...');
        stt = 'n';
        fopen(ser1)
        pause(5)
        while stt == 'n'
            hel = ser1.BytesAvailable;
            if  hel >= 12
                stt = 'y';
                SP = fscanf(ser1);
            end
        end
        fclose(ser1)
        
        sttr = 'n';
        while sttr == 'n'
            tts('Kindly show your face and press Enter when ready')
            preview(vidobj)%,handleToImage)
            pause(5);
            r_face = input('Show your face, Press Enter when ready: ','s');
            I = getsnapshot(vidobj);
            faceDetector = vision.CascadeObjectDetector();
            bbox = step(faceDetector, I);
            r_size = size(bbox);
            if (r_size(1,1) > 1)
                disp('Cannot register two faces.');
                tts('Cannot register two faces.');
            elseif (r_size(1,1) == 0)
               disp('No face detected.');
                tts('No face detected');
            else
                sttr = 'y';
                BRE = bbox(:, 1:4);
                r1 = BRE(1,1);
                c1 = BRE(1,2);
                r2 = r1 + BRE(1,3);
                c2 = c1 + BRE(1,4);
                r_face = I(c1:c2,r1:r2,:);
                r_face = imresize(r_face,[200 200]);
                r_count = r_count + 1;
                face_db{r_count,1} = r_name;
                face_db{r_count,2} = 1;
face_db{r_count,3} = SP;
                face_db{r_count,5} = r_no;
                save('reg_face.mat','face_db','r_count');
                f_name = strcat(r_name,'_fac.jpg');
                imwrite(r_face,f_name,'jpg');
                movefile(f_name,'./register')
                disp('Registration done successfully.');
                tts('Registration done successfully.');
%                 fopen(ser_gsm);
%                 ser_gsm.terminator = 'CR';
%                 fprintf(ser_gsm,'at+cmgf=1');
%                 pause(1)
%                 usr_no = strcat('at+cmgs="',r_no,'"');
%                 fprintf(ser_gsm,usr_no);%Mobile No.
%                 pause(0.5)
%                 ser_gsm.terminator = 26;

                st_url = strcat(' http://103.250.30.5/SendSMS/sendmsg.php?uname=Jeet1234&pass=1234567&send=ALERTS&dest=91',r_no,'&msg=',b);
                str = urlread(st_url);
                
                %                 fprintf(ser_gsm,b);
% %                 disp('SMS Sent!')
%                 fclose(ser_gsm);
            %     imshow(I); hold on
            %     rectangle('Position',BRE,'LineWidth',4,'LineStyle','-','EdgeColor','y'); 
            %     figure, imshow(r_face)

            end
        end
    else
        tts('Name is already registered. Do you want to add face samples to make Training Strong?')
        r_select = input('Name is already registered. Do you want to add face samples to make Training Strong? Press "Y" for yes and "N" to exit.','s');
        r_select = lower(r_select);
        if r_select == 'y'
            sttr = 'n';
        while sttr == 'n'
            tts('Kindly show your face and press Enter when ready')
            preview(vidobj)%,handleToImage)
            pause(5);
            r_face = input('Show your face, Press Enter when ready: ','s');
            I = getsnapshot(vidobj);
            faceDetector = vision.CascadeObjectDetector();
            bbox = step(faceDetector, I);
            r_size = size(bbox);
            if (r_size(1,1) > 1)
                disp('Cannot register two faces.');
                tts('Cannot register two faces.');
            elseif (r_size(1,1) == 0)
               disp('No face detected.');
                tts('No face detected');
            else
                sttr = 'y';
                BRE = bbox(:, 1:4);
                r1 = BRE(1,1);
                c1 = BRE(1,2);
                r2 = r1 + BRE(1,3);
                c2 = c1 + BRE(1,4);
                r_face = I(c1:c2,r1:r2,:);
                r_face = imresize(r_face,[200 200]);
                
                temp_count = face_db{r_count1,2};
                temp_count = temp_count + 1;
                face_db{r_count1,2} = temp_count;
                save('reg_face.mat','face_db','r_count');
                f_name = strcat(r_name,'_fac',int2str(temp_count),'.jpg');
                imwrite(r_face,f_name,'jpg');
                movefile(f_name,'./register')
                disp('Updated face into Training set.');
                tts('Updated face into Training set.');
%                 fopen(ser_gsm);
%                 ser_gsm.terminator = 'CR';
%                 fprintf(ser_gsm,'at+cmgf=1');
%                 pause(1)
%                 usr_no = strcat('at+cmgs="',face_db{r_count1,5},'"');
%                 fprintf(ser_gsm,usr_no);%Mobile No.
%                 pause(0.5)
%                 ser_gsm.terminator = 26;
                b = ['Updated%20face%20into%20Training%20set.'];%Message
                st_url = strcat(' http://103.250.30.5/SendSMS/sendmsg.php?uname=Jeet1234&pass=1234567&send=ALERTS&dest=91',face_db{r_count1,5},'&msg=',b);
                str = urlread(st_url);
%                 fprintf(ser_gsm,b);
% %                 disp('SMS Sent!')
%                 fclose(ser_gsm);
            %     imshow(I); hold on
            %     rectangle('Position',BRE,'LineWidth',4,'LineStyle','-','EdgeColor','y'); 
            %     figure, imshow(r_face)

            end
        end
        end
    end
elseif (N == 3)
    clc
    if r_count  > 0
    disp('Kindly show your RFID card');
        tts('Kindly show your RFID card...');
        stt = 'n';
        fopen(ser1)
        pause(5)
        while stt == 'n'
            hel = ser1.BytesAvailable;
            if  hel >= 12
                stt = 'y';
                SP = fscanf(ser1);
            end
        end
        fclose(ser1)
        for i=1:r_count
        if (strcmp(SP,face_db{i,3}))
            rf_entry = 1;
            rf_count1 = i;
            break
        else
            rf_entry = 0;
        end
        end
        
        if rf_entry == 1
           tts('Enter Amount to Refill.')
            r_balance = input('Enter Amount to Refill->');
            r_balance = lower(r_balance);
            temp_balance = face_db{rf_count1,4} + r_balance;
            face_db{rf_count1,4} = temp_balance;
            save('reg_face.mat','face_db','r_count');
            bdt = strcat('Refill Amount: Rs.', int2str(r_balance), '/-');
            bdb = strcat('Account Balance: Rs.', int2str(face_db{rf_count1,4}), '/-');
            disp('Balance successfully refilled.')
            tts('Balance successfully refilled.')
            disp(bdt)
            disp(bdb)
%             fopen(ser_gsm);
%             ser_gsm.terminator = 'CR';
%             fprintf(ser_gsm,'at+cmgf=1');
%             pause(1)
%             usr_no = strcat('at+cmgs="',face_db{rf_count1,5},'"');
%             fprintf(ser_gsm,usr_no);%Mobile No.
%             pause(0.5)
                                
            b = strcat('Refill%20Amount:%20Rs.', int2str(r_balance), '/-,%20');
            c = strcat('Account%20Balance:%20Rs.', int2str(face_db{rf_count1,4}), '/-,%20');
            d = ('Balance%20successfully%20refilled.');
            st_url = strcat(' http://103.250.30.5/SendSMS/sendmsg.php?uname=Jeet1234&pass=1234567&send=ALERTS&dest=91',face_db{rf_count1,5},'&msg=',b,c,d);
                str = urlread(st_url);
%             fprintf(ser_gsm,b);
%             fprintf(ser_gsm,c);
%             ser_gsm.terminator = 26;
%             fprintf(ser_gsm,d);
%                 %                 disp('SMS Sent!')
%             fclose(ser_gsm);
        else
            disp('RFID not registered')
            tts('RFID not registered')
            
        end
    else
        disp('Kindly Register atleast one user.')
        tts('Kindly Register atleast one user.')
    end
elseif (N == 2)
    clc
    if r_count  > 0
    disp('Kindly show your RFID card');
        tts('Kindly show your RFID card...');
        stt = 'n';
        fopen(ser1)
        pause(5)
        while stt == 'n'
            hel = ser1.BytesAvailable;
            if  hel >= 12
                stt = 'y';
                SP = fscanf(ser1);
            end
        end
        fclose(ser1)
        for i=1:r_count
        if (strcmp(SP,face_db{i,3}))
            rf_entry = 1;
            rf_count1 = i;
            break
        else
            rf_entry = 0;
        end
        end
        
        if rf_entry == 1
           disp('RFID identified.')
           tts('RFID identified.')
           rf_name = face_db{rf_count1,1};
           sttr = 'f';
           
           while sttr == 'f'
               tts('Proceed without Face?');
               t_pref = input('Proceed without Face? (1 - Yes, 0 -  No) -->');
               if (t_pref == 0)
                  sttr = 'n';
               elseif (t_pref == 1)
                  sttr = 'w';
               else
                   tts('Invalid Input. Try again')
                   clc
               end
           end
           while sttr == 'w'
%                sttr = 'e';
               ran_sms = randi(9,1,6);
               ran_sms1 = int2str(ran_sms);
               brk = findstr(ran_sms1,' ');
               leng_brk = size(brk,2);
               for i = 1:leng_brk
               ran_sms1(brk(1)) = [];
               brk = findstr(ran_sms1,' ');
               ran_sms1;
               end
               b = ('Your%20OTP%20is%20');
               c = ran_sms1;
               st_url = strcat(' http://103.250.30.5/SendSMS/sendmsg.php?uname=Jeet1234&pass=1234567&send=ALERTS&dest=91',face_db{rf_count1,5},'&msg=',b,c);
               str = urlread(st_url);
               disp('OTP Sent. Check your registered Mobile Number.');
               tts('OTP Sent. Check your registered Mobile Number. Enter OTP');
               t_otp = input('Enter OTP -->');
               t_otp1 = int2str(t_otp);
               if (strcmp(t_otp1,ran_sms1))
                    sttr = 'e';
               else
                   sttr = 'j';
                   disp('Invalid OTP.');
                   tts('Invalid OTP.');
                   b = ('Invalid%20OTP.');
                   st_url = strcat(' http://103.250.30.5/SendSMS/sendmsg.php?uname=Jeet1234&pass=1234567&send=ALERTS&dest=91',face_db{rf_count1,5},'&msg=',b);
                   str = urlread(st_url);
               end
               while sttr == 'e';
                   sttr = 'x';
               dd = strcat('Welcome: ', rf_name);
                           disp (dd)
                           tts(dd)
                           tts('Enter transcation amount.')
                           t_balance = input('Enter transaction amount->');
                           t_balance = lower(t_balance);
                           temp_balance = face_db{rf_count1,4};
                           if (t_balance > temp_balance)
                              disp('Insuficient Balance in account.') 
                              tts('Insuficient Balance in account.') 
                              ddb = strcat('Account Balance: Rs.', int2str(face_db{rf_count1,4}), '/-');
                              disp(ddb)
                              disp('Transaction Failed.') 
                           else
                               face_db{rf_count1,4} = temp_balance - t_balance;
                               save('reg_face.mat','face_db','r_count');
                               ddt = strcat('Transaction Amount: Rs.', int2str(t_balance),   '/-');
                               ddb = strcat('Account Balance: Rs.', int2str(face_db{rf_count1,4}), '/-');
                               disp('Transaction successfully done.')
                               disp(ddt)
                               disp(ddb)
                               tts('Transaction successfully done.')
%                                fopen(ser_gsm);
%                                 ser_gsm.terminator = 'CR';
%                                 fprintf(ser_gsm,'at+cmgf=1');
%                                 pause(1)
%                                 usr_no = strcat('at+cmgs="',face_db{rf_count1,5},'"');
%                                 fprintf(ser_gsm,usr_no);%Mobile No.
%                                 pause(0.5)
                                
                                b = strcat('Transaction%20Amount:%20Rs.', int2str(t_balance), '/-,%20');
                                c = strcat('Account%20Balance:%20Rs.', int2str(face_db{rf_count1,4}), '/-,%20');
                                d = ('Transaction%20Successfully%20Done.');
                                st_url = strcat(' http://103.250.30.5/SendSMS/sendmsg.php?uname=Jeet1234&pass=1234567&send=ALERTS&dest=91',face_db{rf_count1,5},'&msg=',b,c,d);
                                str = urlread(st_url);
%                                 fprintf(ser_gsm,b);
%                                 fprintf(ser_gsm,c);
%                                 ser_gsm.terminator = 26;
%                                 fprintf(ser_gsm,d);
%                 %                 disp('SMS Sent!')
%                                 fclose(ser_gsm);
                           end
               end
           end
            while sttr == 'n'
                tts('Kindly show your face and press Enter when ready')
                preview(vidobj)%,handleToImage)
                pause(5);
                r_face = input('Show your face, Press Enter when ready: ','s');
                I = getsnapshot(vidobj);
                faceDetector = vision.CascadeObjectDetector();
                bbox = step(faceDetector, I);
                r_size = size(bbox);
                if (r_size(1,1) > 1)
                    disp('Cannot recognise two faces.');
                    tts('Cannot recognise two faces.');
                elseif (r_size(1,1) == 0)
                   disp('No face detected.');
                    tts('No face detected');
                else
                    sttr = 'y';
                    BRE = bbox(:, 1:4);
                    r1 = BRE(1,1);
                    c1 = BRE(1,2);
                    r2 = r1 + BRE(1,3);
                    c2 = c1 + BRE(1,4);
                    t_snap = I(c1:c2,r1:r2,:);
                    t_snap = imresize(t_snap,[200 200]);
                    TrainFiles = dir(TrainDatabasePath);
                    t_snap1 = rgb2gray(t_snap);
                    Train_Number = 0;
                    Euc_dist = [];
                    for ij = 1:size(TrainFiles,1)
                        if not(strcmp(TrainFiles(ij).name,'.')|strcmp(TrainFiles(ij).name,'..')|strcmp(TrainFiles(ij).name,'Thumbs.db'))
                            Train_Number = Train_Number + 1; % Number of all images in the training database
            %                 t_snap1 = rgb2gray(t_face{i});
                            str = strcat(TrainDatabasePath,'\',TrainFiles(ij).name);
                            img = imread(str);
                            db_snap = rgb2gray(img);
                            temp_cmp = corr2(t_snap1,db_snap);
                            Euc_dist = [Euc_dist temp_cmp];
                        end

                    end
                        [Euc_dist_min , Recognized_index] = max(Euc_dist);
                        Recognized_index = Recognized_index + 2;
                            % OutputName = strcat(int2str(Recognized_index),'.jpg');
                        OutputName = TrainFiles(Recognized_index).name;
                        k = strfind(OutputName,'_');
                        FinalName = OutputName(1:k-1);
                        if (strcmp(rf_name,FinalName))
                           disp('Face Recognised')
                           tts('Face Recognised')
                           dd = strcat('Welcome: ', FinalName);
                           disp (dd)
                           tts(dd)
                           ran_sms = randi(9,1,6);
                           ran_sms1 = int2str(ran_sms);
                           brk = findstr(ran_sms1,' ');
                           leng_brk = size(brk,2);
                           for i = 1:leng_brk
                           ran_sms1(brk(1)) = [];
                           brk = findstr(ran_sms1,' ');
                           ran_sms1;
                           end
                           b = ('Your%20OTP%20is%20');
                           c = ran_sms1;
                           st_url = strcat(' http://103.250.30.5/SendSMS/sendmsg.php?uname=Jeet1234&pass=1234567&send=ALERTS&dest=91',face_db{rf_count1,5},'&msg=',b,c);
                           str = urlread(st_url);
                           disp('OTP Sent. Check your registered Mobile Number.');
                           tts('OTP Sent. Check your registered Mobile Number. Enter OTP');
                           t_otp = input('Enter OTP -->');
                           t_otp1 = int2str(t_otp);
                           if (strcmp(t_otp1,ran_sms1))
                                sttr = 'f';
                           else
                               sttr = 'j';
                               disp('Invalid OTP.');
                               tts('Invalid OTP.');
                               b = ('Invalid%20OTP.');
                               st_url = strcat(' http://103.250.30.5/SendSMS/sendmsg.php?uname=Jeet1234&pass=1234567&send=ALERTS&dest=91',face_db{rf_count1,5},'&msg=',b);
                               str = urlread(st_url);
                           end
                           while (sttr == 'f')
                               sttr = 'x';
                           tts('Enter transcation amount.')
                           t_balance = input('Enter transaction amount->');
                           t_balance = lower(t_balance);
                           temp_balance = face_db{rf_count1,4};
                           if (t_balance > temp_balance)
                              disp('Insuficient Balance in account.') 
                              tts('Insuficient Balance in account.') 
                              ddb = strcat('Account Balance: Rs.', int2str(face_db{rf_count1,4}), '/-');
                              disp(ddb)
                              disp('Transaction Failed.') 
                           else
                               face_db{rf_count1,4} = temp_balance - t_balance;
                               save('reg_face.mat','face_db','r_count');
                               ddt = strcat('Transaction Amount: Rs.', int2str(t_balance), '/-');
                               ddb = strcat('Account Balance: Rs.', int2str(face_db{rf_count1,4}), '/-');
                               disp('Transaction successfully done.')
                               disp(ddt)
                               disp(ddb)
                               tts('Transaction successfully done.')
%                                fopen(ser_gsm);
%                                 ser_gsm.terminator = 'CR';
%                                 fprintf(ser_gsm,'at+cmgf=1');
%                                 pause(1)
%                                 usr_no = strcat('at+cmgs="',face_db{rf_count1,5},'"');
%                                 fprintf(ser_gsm,usr_no);%Mobile No.
%                                 pause(0.5)
                                
                                b = strcat('Transaction%20Amount:%20Rs.', int2str(t_balance), '/-, ');
                                c = strcat('Account%20Balance:%20Rs.', int2str(face_db{rf_count1,4}), '/-, ');
                                d = ('Transaction%20Successfully%20Done.');
                                st_url = strcat(' http://103.250.30.5/SendSMS/sendmsg.php?uname=Jeet1234&pass=1234567&send=ALERTS&dest=91',face_db{rf_count1,5},'&msg=',b,c,d);
                                str = urlread(st_url);
%                                 fprintf(ser_gsm,b);
%                                 fprintf(ser_gsm,c);
%                                 ser_gsm.terminator = 26;
%                                 fprintf(ser_gsm,d);
%                 %                 disp('SMS Sent!')
%                                 fclose(ser_gsm);
                           end
                            end
                        else
                              disp('Face did not matched with database.') 
                              tts('Face did not matched with database.') 
                              disp('Transaction Failed.') 
%                               fopen(ser_gsm);
%                                 ser_gsm.terminator = 'CR';
%                                 fprintf(ser_gsm,'at+cmgf=1');
%                                 pause(1)
%                                 usr_no = strcat('at+cmgs="',face_db{rf_count1,5},'"');
%                                 fprintf(ser_gsm,usr_no);%Mobile No.
%                                 pause(0.5)
%                                 ser_gsm.terminator = 26;
                                b = ['Face%20did%20not%20matched%20with%20database.Transaction Failed.'];%Message
                                st_url = strcat(' http://103.250.30.5/SendSMS/sendmsg.php?uname=Jeet1234&pass=1234567&send=ALERTS&dest=91',face_db{rf_count1,5},'&msg=',b);
                                str = urlread(st_url);
%                                 fprintf(ser_gsm,b);
%                 %                 disp('SMS Sent!')
%                                 fclose(ser_gsm);
                        end
                end
            end
        else
            disp('RFID not registered')
            tts('RFID not registered')
            
        end
    else
        disp('Kindly Register atleast one user.')
        tts('Kindly Register atleast one user.')
    end
elseif (N == 4)
    clc
    face_db = cell(10,5);
    for i=1:10
        face_db{i,4} = 1000;
    end
    r_count = 0;
    save('reg_face.mat','face_db','r_count');
    disp('Reset of Matlab DataBase done. Kindly delete photos from Register Folder.')
    tts('Reset of Matlab DataBase done. Kindly delete photos from Register Folder.')
elseif (N == 5)
    clc
    st_menu = 'n';
end
end
