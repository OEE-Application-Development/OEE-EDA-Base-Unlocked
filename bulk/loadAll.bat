REM Disabling TDTM triggers
start "Disable TDTM" /wait /b cci task run disable_tdtm_trigger_handlers --namespace hed

REM Organization Accounts
call sf data import bulk -s Account --file "bulk/data/InstitutionAccounts.csv" -w 10 --column-delimiter=COMMA
call sf apex run --file bulk/recordtypes/setInstitutionRecordType.apex

call sf data import bulk -s Account --file "bulk/data/CollegeAccounts.csv" -w 10 --column-delimiter=COMMA
call sf apex run --file bulk/recordtypes/setCollegeRecordType.apex

call sf data import bulk -s Account --file "bulk/data/DepartmentAccounts.csv" -w 10 --column-delimiter=COMMA
call sf apex run --file bulk/recordtypes/setDepartmentRecordType.apex

REM Banner Account/Contact Pull -- Get Accounts / Link Contacts / Re-update primary Contact on Account
call sf data import bulk -s Account --file "bulk/data/BannerAccounts.csv" -w 10 --column-delimiter=COMMA
call sf apex run --file bulk/recordtypes/setBannerAccountRecordType.apex
call sf data import bulk -s Contact --file "bulk/data/BannerContacts.csv" -w 10 --column-delimiter=COMMA
call sf data upsert bulk -s Account -i hed__School_Code__c --file "bulk/data/BannerAccountsPrimaryContact.csv" -w 10 --column-delimiter=COMMA

call sf data import bulk -s Account --file "bulk/data/AcademicPrograms.csv" -w 10 --column-delimiter=COMMA
REM call sf apex run --file bulk/recordtypes/setAcademicProgramRecordType.apex -- Not needed in Base, default type is Academic Program. Also why it's last.

REM EDA/Canvas Objects Terms/Courses/Course Offerings/Enrollments
call sf data import bulk -s hed__Term__c --file "bulk/data/CreditTerms.csv" -w 10 --column-delimiter=COMMA
REM call sf apex run --file bulk/recordtypes/setCreditTermRecordType.apex -- Credit is default.
call sf data import bulk -s hed__Course__c --file "bulk/data/CreditCourses.csv" -w 10 --column-delimiter=COMMA
REM call sf apex run --file bulk/recordtypes/setCreditCourseRecordType.apex -- Credit is default.
call sf data import bulk -s csuoee__Part_of_Term__c --file "bulk/data/PartsOfTerm.csv" -w 10 --column-delimiter=COMMA
call sf data import bulk -s hed__Course_Offering__c --file "bulk/data/CreditSections.csv" -w 10 --column-delimiter=COMMA
call sf data import bulk -s hed__Course_Offering_Schedule__c --file "bulk/data/CreditSectionSchedules.csv" -w 10 --column-delimiter=COMMA
call sf data import bulk -s hed__Course_Enrollment__c --file "bulk/data/CreditStudentEnrollments.csv" -w 10 --column-delimiter=COMMA
REM call sf apex run --file bulk/recordtypes/setStudentEnrollmentRecordType.apex -- Credit is default.

REM Re-Enabling TDTM triggers
start "Enable TDTM" /wait /b cci task run restore_tdtm_trigger_handlers --namespace hed