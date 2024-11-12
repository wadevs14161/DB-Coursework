------------------- ResourceLimit table -------------------
CREATE TABLE ResourceLimit (
    memberType VARCHAR2(20) PRIMARY KEY CHECK (memberType IN ('Student', 'Staff')),
    resourceLimit INT CHECK (resourceLimit >= 0) -- Ensures resourceLimit is non-negative
);






------------------- Member table -------------------
CREATE TABLE Member (
    memberId VARCHAR2(100) PRIMARY KEY,
    memberName VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    DOB DATE,
    memberType VARCHAR2(20),
    totalFine NUMBER DEFAULT 0 CHECK (totalFine >= 0), 
    totalLoan NUMBER DEFAULT 0 CHECK (totalLoan >= 0),
    reservationFailed NUMBER DEFAULT 0 CHECK (reservationFailed >= 0),
    FOREIGN KEY (memberType) REFERENCES ResourceLimit(memberType)
);

/* Constrain for DOB */
CREATE OR REPLACE TRIGGER trg_check_dob
BEFORE INSERT OR UPDATE ON Member
FOR EACH ROW
BEGIN
    IF :NEW.DOB >= SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'Date of Birth must be in the past.');
    END IF;
END;
/





------------------- Location table -------------------
CREATE TABLE Location (
    locationId VARCHAR2(100) PRIMARY KEY,
    floorNumber INT CHECK (floorNumber <= 3),
    shelfNumber INT,
    sectionName VARCHAR2(50),
    classNumber VARCHAR2(50) UNIQUE
);





------------------- Resources table -------------------
CREATE TABLE Resources (
    resourceId VARCHAR2(100) PRIMARY KEY,
    resourceType VARCHAR2(50) CHECK (resourceType IN ('book', 'eBook', 'device')),
    locationId VARCHAR2(100),
    borrowRule VARCHAR2(50) CHECK (borrowRule IN ('normal', 'short', 'onSite')),
    digitalCopy INT CHECK (digitalCopy >= 0),
	availability NUMBER(1) DEFAULT 1 CHECK (availability IN (0, 1)), -- 0 for unavailable, 1 for available
    classNumber VARCHAR2(50),
    resourceTitle VARCHAR2(200) NOT NULL,
    FOREIGN KEY (locationId) REFERENCES Location(locationId) ON DELETE CASCADE,  -- Cascades delete for locationId
    FOREIGN KEY (classNumber) REFERENCES Location(classNumber) ON DELETE CASCADE  -- Cascades delete for classNumber
);

/* Constrain for resources type */

-- Trigger for when a new eBook resource is added
CREATE OR REPLACE TRIGGER trg_check_ebook
BEFORE INSERT ON Resources
FOR EACH ROW
BEGIN
    IF :NEW.resourceType = 'eBook' THEN
        -- Ensure digitalCopy is not NULL and locationId is NULL for eBooks
        IF :NEW.digitalCopy IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Digital Copy must not be NULL for eBooks.');
        END IF;
        IF :NEW.locationId IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'LocationId must be NULL for eBooks.');
        END IF;
    END IF;
END;
/

-- Trigger for when a new book resource is added
CREATE OR REPLACE TRIGGER trg_check_book
BEFORE INSERT ON Resources
FOR EACH ROW
BEGIN
    IF :NEW.resourceType = 'book' THEN
        -- Ensure digitalCopy is NULL and classNumber is not NULL for books
        IF :NEW.digitalCopy IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20004, 'Digital Copy must be NULL for books.');
        END IF;
        IF :NEW.classNumber IS NULL THEN
            RAISE_APPLICATION_ERROR(-20005, 'ClassNumber must not be NULL for books.');
        END IF;
    END IF;
END;
/

-- Trigger for when a new device resource is added
CREATE OR REPLACE TRIGGER trg_check_device
BEFORE INSERT ON Resources
FOR EACH ROW
BEGIN
    IF :NEW.resourceType = 'device' THEN
        -- Ensure digitalCopy is NULL and classNumber is NULL for devices
        IF :NEW.digitalCopy IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20006, 'Digital Copy must be NULL for devices.');
        END IF;
        IF :NEW.classNumber IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20007, 'ClassNumber must be NULL for devices.');
        END IF;
    END IF;
END;
/






------------------- Loan table -------------------
CREATE TABLE Loan (
    loanId VARCHAR2(100) PRIMARY KEY,
    memberId VARCHAR2(100) NOT NULL,
    resourceId VARCHAR2(100) NOT NULL,
    loanDate DATE DEFAULT SYSDATE,
    dueDate DATE,
    returnDate DATE,
    FOREIGN KEY (memberId) REFERENCES Member(memberId) ON DELETE CASCADE,
    FOREIGN KEY (resourceId) REFERENCES Resources(resourceId) ON DELETE CASCADE
);


/* Constrain for dueDate and returnDate */
CREATE OR REPLACE TRIGGER trg_check_loan_dates
BEFORE INSERT OR UPDATE ON Loan
FOR EACH ROW
BEGIN
    IF :NEW.dueDate <= :NEW.loanDate THEN
        RAISE_APPLICATION_ERROR(-20008, 'Due Date must be after Loan Date.');
    END IF;

    IF :NEW.returnDate <= :NEW.loanDate THEN
        RAISE_APPLICATION_ERROR(-20009, 'Return Date must be after Loan Date.');
    END IF;
END;






------------------- Reservation table -------------------
CREATE TABLE Reservation (
    reservationId VARCHAR2(100) PRIMARY KEY,
    memberId VARCHAR2(100) NOT NULL,
    resourceId VARCHAR2(100) NOT NULL,
    reservationDate DATE DEFAULT SYSDATE,
    expirationDate DATE,
    FOREIGN KEY (memberId) REFERENCES Member(memberId) ON DELETE CASCADE,
    FOREIGN KEY (resourceId) REFERENCES Resources(resourceId) ON DELETE CASCADE
);


/* Constrain for expirationDate */
CREATE OR REPLACE TRIGGER trg_check_reservation_dates
BEFORE INSERT OR UPDATE ON Reservation
FOR EACH ROW
BEGIN
    IF :NEW.expirationDate <= :NEW.reservationDate THEN
        RAISE_APPLICATION_ERROR(-20010, 'Expiration Date must be after Reservation Date.');
    END IF;
END;


