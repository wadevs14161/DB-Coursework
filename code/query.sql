-- Test create loan (valid)
INSERT INTO Loan (loanId, memberId, resourceId)
VALUES
('a909f05a-9e03-487a-a7d5-2322585e5eab', '082413d4-7897-4ef9-b69e-c7d65514d6c4', 'a846cbd1-b13f-4d50-9283-ff8dfe5f39db');

-- Test return book (valid)
UPDATE loan
SET returnDate = TO_DATE('2024-11-17', 'YYYY-MM-DD')
WHERE loanId = 'a909f05a-9e03-487a-a7d5-2322585e5eab';