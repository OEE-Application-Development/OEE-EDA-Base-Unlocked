REM Organization Accounts
call sf data export bulk --query-file "bulk/query/InstitutionAccounts.soql" --output-file "bulk/data/InstitutionAccounts.csv" -w 10
call sf data export bulk --query-file "bulk/query/CollegeAccounts.soql" --output-file "bulk/data/CollegeAccounts.csv" -w 10
call sf data export bulk --query-file "bulk/query/DepartmentAccounts.soql" --output-file "bulk/data/DepartmentAccounts.csv" -w 10

REM Banner Account/Contact Pull -- Get Accounts / Link Contacts / Re-update primary Contact on Account
call sf data export bulk --query-file "bulk/query/BannerAccounts.soql" --output-file "bulk/data/BannerAccounts.csv" -w 10
call sf data export bulk --query-file "bulk/query/BannerContacts.soql" --output-file "bulk/data/BannerContacts.csv" -w 10
call sf data export bulk --query-file "bulk/query/BannerAccountsPrimaryContact.soql" --output-file "bulk/data/BannerAccountsPrimaryContact.csv" -w 10

REM EDA/Canvas Objects Terms/Courses/Course Offerings/Enrollments
call sf data export bulk --query-file "bulk/query/CreditTerms.soql" --output-file "bulk/data/CreditTerms.csv" -w 10
call sf data export bulk --query-file "bulk/query/CreditCourses.soql" --output-file "bulk/data/CreditCourses.csv" -w 10
call sf data export bulk --query-file "bulk/query/CreditBuildingFacilities.soql" --output-file "bulk/data/CreditBuildingFacilities.csv" -w 10
call sf data export bulk --query-file "bulk/query/CreditRoomFacilities.soql" --output-file "bulk/data/CreditRoomFacilities.csv" -w 10
call sf data export bulk --query-file "bulk/query/PartsOfTerm.soql" --output-file "bulk/data/PartsOfTerm.csv" -w 10
call sf data export bulk --query-file "bulk/query/CreditSections.soql" --output-file "bulk/data/CreditSections.csv" -w 10
call sf data export bulk --query-file "bulk/query/CreditSectionSchedules.soql" --output-file "bulk/data/CreditSectionSchedules.csv" -w 10
call sf data export bulk --query-file "bulk/query/CreditStudentEnrollments.soql" --output-file "bulk/data/CreditStudentEnrollments.csv" -w 10

REM Opus Registrations
REM call sf data export bulk --query-file "bulk/query/OpusRegistrations.soql" --output-file "bulk/data/OpusRegistrations.csv" -w 10
REM call sf data export bulk --query-file "bulk/query/OpusRegistrationLineItems.soql" --output-file "bulk/data/OpusRegistrationLineItems.csv" -w 10