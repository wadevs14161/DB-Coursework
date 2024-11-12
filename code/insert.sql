------------------- Insert sample data -------------------

/* 1. Inserting a row into the resourceLimit which is mentioned in the description */
INSERT INTO ResourceLimit (memberType, resourceLimit)
VALUES
('Student', 5);

INSERT INTO ResourceLimit (memberType, resourceLimit)
VALUES
('Staff', 10);

/* 2. Inserting a row into the Member table is triggered when a new member is added to the system */

-- Inserting 5 rows into the Member table
INSERT INTO Member (memberId, memberName, email, DOB, memberType, totalFine, totalLoan, reservationFailed)
VALUES 
('082413d4-7897-4ef9-b69e-c7d65514d6c4', 'Alan Li', 'ec24279@qmul.ac.uk', TO_DATE('2001/10/23', 'YYYY/MM/DD'), 'Student', DEFAULT, DEFAULT, DEFAULT);

INSERT INTO Member (memberId, memberName, email, DOB, memberType, totalFine, totalLoan, reservationFailed)
VALUES 
('9a703c27-bb79-4b4f-b9c2-2b5044f0b40b', 'Maria Zhang', 'maria.zhang@qmul.ac.uk', TO_DATE('1999/04/15', 'YYYY/MM/DD'), 'Staff', DEFAULT, DEFAULT, DEFAULT);

INSERT INTO Member (memberId, memberName, email, DOB, memberType, totalFine, totalLoan, reservationFailed)
VALUES 
('b1c3fc3a-1f13-4db5-9b6e-531458773c96', 'John Doe', 'johndoe@mail.com', TO_DATE('1997/02/10', 'YYYY/MM/DD'), 'Student', DEFAULT, DEFAULT, DEFAULT);

INSERT INTO Member (memberId, memberName, email, DOB, memberType, totalFine, totalLoan, reservationFailed)
VALUES 
('d1a0ac9a-3fbc-4664-b5ed-4d4220d517d7', 'Sophia Chen', 'sophia.chen@qmul.ac.uk', TO_DATE('2000/11/05', 'YYYY/MM/DD'), 'Student', DEFAULT, DEFAULT, DEFAULT);

INSERT INTO Member (memberId, memberName, email, DOB, memberType, totalFine, totalLoan, reservationFailed)
VALUES 
('a4f5eb5e-37f2-4b6e-baa2-713a3780d6e2', 'James Li', 'james.li@qmul.ac.uk', TO_DATE('1998/07/22', 'YYYY/MM/DD'), 'Staff', DEFAULT, DEFAULT, DEFAULT);

-- Inserting invalid rows into the Member table
INSERT INTO Member (memberId, memberName, email, DOB, memberType, totalFine, totalLoan, reservationFailed)
VALUES (
    '12345678-1234-1234-1234-1234567890ab', -- Invalid memberId
    'Invalid User',                         -- Name
    'invalid.user@example.com',             -- Email
    TO_DATE('2025-01-01', 'YYYY-MM-DD'),    -- Invalid DOB (future date, violates the trigger)
    'Student',                              -- memberType
    0,                                      -- totalFine
    0,                                      -- totalLoan
    0                                       -- reservationFailed
);


/* 3. Inserting some rows into the Location table */

-- Location 1: Floor number 1
INSERT INTO Location (locationId, floorNumber, shelfNumber, sectionName, classNumber)
VALUES ('4e8f9b5a-d684-42f2-90e3-05d679b8d87f', 1, 1, 'Computer Science', 'C001');

-- Location 2: Floor number 2
INSERT INTO Location (locationId, floorNumber, shelfNumber, sectionName, classNumber)
VALUES ('d91f9fbc-3483-4aeb-a9d5-b1aeb5e8589a', 2, 2, 'Mathematics', 'C002');

-- Location 3: Floor number 3
INSERT INTO Location (locationId, floorNumber, shelfNumber, sectionName, classNumber)
VALUES ('b77b2c66-cf66-4b33-bec4-524d54996785', 3, 3, 'Physics', 'C003');

-- Location 4: Floor number 1
INSERT INTO Location (locationId, floorNumber, shelfNumber, sectionName, classNumber)
VALUES ('f51c29fe-cf52-4386-b01a-9352b232e759', 1, 2, 'Chemistry', 'C004');

-- Location 5: Floor number 2
INSERT INTO Location (locationId, floorNumber, shelfNumber, sectionName, classNumber)
VALUES ('9c9a1cc5-9d0a-4e1f-87cd-56e824f8d77e', 2, 5, 'Biology', 'C005');

/* 4. Inserting some rows into the Resources table */
-- Resource 1: Book
INSERT INTO Resources (resourceId, resourceType, locationId, borrowRule, digitalCopy, availability, classNumber, resourceTitle)
VALUES ('da72a314-d592-432b-920b-8bfc5a9f0a3e', 'book', '4e8f9b5a-d684-42f2-90e3-05d679b8d87f', 'normal', NULL, 1, 'C001', 'Introduction to Computer Science');

-- Resource 2: eBook
INSERT INTO Resources (resourceId, resourceType, locationId, borrowRule, digitalCopy, availability, classNumber, resourceTitle)
VALUES ('b213c1e5-d899-41c0-b0c6-bb7b3a3347b4', 'eBook', NULL, 'normal', 1, 1, NULL, 'Data Structures and Algorithms');

-- Resource 3: Device
INSERT INTO Resources (resourceId, resourceType, locationId, borrowRule, digitalCopy, availability, classNumber, resourceTitle)
VALUES ('d6f8a699-7087-4f77-b490-1a70c3a99125', 'device', NULL, 'onSite', NULL, 1, NULL, 'Laptop for Programming');

-- Resource 4: Book
INSERT INTO Resources (resourceId, resourceType, locationId, borrowRule, digitalCopy, availability, classNumber, resourceTitle)
VALUES ('a846cbd1-b13f-4d50-9283-ff8dfe5f39db', 'book', 'd91f9fbc-3483-4aeb-a9d5-b1aeb5e8589a', 'short', NULL, 1, 'C002', 'Advanced Mathematics');

-- Resource 5: eBook
INSERT INTO Resources (resourceId, resourceType, locationId, borrowRule, digitalCopy, availability, classNumber, resourceTitle)
VALUES ('679b9a02-d568-4c0f-9c57-75c3f21e9c64', 'eBook', NULL, 'normal', 1, 1, NULL, 'Machine Learning Basics');

-- Resource 6: Device
INSERT INTO Resources (resourceId, resourceType, locationId, borrowRule, digitalCopy, availability, classNumber, resourceTitle)
VALUES ('cf3fd2b0-4c71-4f95-9253-f325fb15b7ac', 'device', NULL, 'onSite', NULL, 1, NULL, 'Projector for Class');


/* 5. Inserting some rows into the Loan table to simulate some user borrow a resource */

-- Alan Li borrow Advanced Mathematics

-- Step 1  check the eligibility of that member from the View table(toalFine <= 10 totalLoan <= limit)

-- create a view named MemberEligibility to help us determine the member's eligibility
CREATE OR REPLACE VIEW MemberEligibility AS
SELECT 
    m.memberId,
    m.memberName,
    CASE 
        WHEN m.totalFine <= 10 AND m.totalLoan <= rl.resourceLimit THEN 1
        ELSE 0
    END AS eligibility
FROM 
    Member m
JOIN 
    ResourceLimit rl ON m.memberType = rl.memberType;

-- check the eligibility
SELECT
    me.eligibility
FROM
    MemberEligibility me
WHERE
    me.memberId = '082413d4-7897-4ef9-b69e-c7d65514d6c4';


-- Step 2: check the availability of the resource from the Resource table
SELECT
    r.availability
FROM
    Resources r
WHERE
    r.resourceId = 'a846cbd1-b13f-4d50-9283-ff8dfe5f39db';

-- Step 3: create a record of Loan
-- Only if both eligibility and availability is equal to 1, create the record

-- Step 3: Insert a loan record
-- Step 3: Insert a loan record with dynamic dueDate based on borrowRule
INSERT INTO Loan (loanId, memberId, resourceId, loanDate, dueDate)
SELECT
    SYS_GUID(),  -- Generates a unique loanId using UUID
    '082413d4-7897-4ef9-b69e-c7d65514d6c4',  -- Member ID
    'a846cbd1-b13f-4d50-9283-ff8dfe5f39db',  -- Resource ID
    SYSDATE,  -- Current date for loan date
    CASE 
        WHEN r.borrowRule = 'normal' THEN SYSDATE + 21  -- 3 weeks for normal
        WHEN r.borrowRule = 'short' THEN SYSDATE + 3   -- 3 days for short
        WHEN r.borrowRule = 'onSite' THEN SYSDATE      -- same day for on-site
        ELSE SYSDATE  -- default to current date if no rule matches
    END AS dueDate
FROM
    Resources r
WHERE
    r.resourceId = 'a846cbd1-b13f-4d50-9283-ff8dfe5f39db'
    AND (SELECT eligibility FROM MemberEligibility me WHERE me.memberId = '082413d4-7897-4ef9-b69e-c7d65514d6c4') = 1
    AND r.availability = 1;



-- Step 4: update the resource availability to False and update the totalLoan of the member +1

-- Update the availability of the resource (set to 0 because it's borrowed)
UPDATE Resources
SET availability = 0
WHERE resourceId = 'a846cbd1-b13f-4d50-9283-ff8dfe5f39db';

-- Update the totalLoan of the member (increment by 1)
UPDATE Member
SET totalLoan = totalLoan + 1
WHERE memberId = '082413d4-7897-4ef9-b69e-c7d65514d6c4';




