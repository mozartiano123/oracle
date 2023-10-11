create or replace FUNCTION SPRINT_PASS_VERIFY (username varchar2, password varchar2, old_password varchar2)
   RETURN boolean IS
   min_pwd_len                      constant number(1) := 8;
   digitarray                       constant varchar2(20) := '0123456789';
   chararray                        constant varchar2(52) := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

   n                                 boolean;
   m                                integer;
   differ                           integer;
   same_chrs                   integer;
   isdigit                          boolean;
   ischar                          boolean;
   ispunct                        boolean;

BEGIN
   -- Check if the password is same as the username
   IF NLS_LOWER(password) = NLS_LOWER(username) THEN
     raise_application_error(-20001, 'Password same as username');
   END IF;

   -- Check for the minimum length of the password
   IF length(password) < min_pwd_len THEN
      raise_application_error(-20002, 'Password length less than '||ltrim(to_char(min_pwd_len))||' characters');

   END IF;

   -- Check if the password is too simple. A dictionary of words may be
   -- maintained and a check may be made so as not to allow the words
   -- that are too simple for the password.
   IF NLS_LOWER(password) IN ('welcome', 'database', 'account', 'user', 'password',

                              'oracle00', 'computer0', 'abcdefg', 'microsoft0',
                              'sqlserver0','sprint99','sprint2k','sprintldd00',
                              'sprint07','nextel') THEN
      raise_application_error(-20002, 'Password too simple');
   END IF;

   -- Check if the password contains at least one letter, and one digit.
   -- 1. Check for the digit
   isdigit:=FALSE;
   m := length(password);
   FOR i IN 1..10 LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(digitarray,i,1) THEN
            isdigit:=TRUE;
             GOTO findchar;
         END IF;
      END LOOP;
   END LOOP;
   IF isdigit = FALSE THEN
      raise_application_error(-20003, 'Password must contain at least one character from each of these types: alphabetic and numeric');

   END IF;

   -- 2. Check for the character
   <<findchar>>
   ischar:=FALSE;
   FOR i IN 1..length(chararray) LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(chararray,i,1) THEN
            ischar:=TRUE;
             GOTO endsearch;
         END IF;
      END LOOP;
   END LOOP;
   IF ischar = FALSE THEN
      raise_application_error(-20003, 'Password must contain at least one character from each of these types: alphabetic and numeric');

   END IF;

   <<endsearch>>
   -- Check if the password differs from the previous password by at least
   -- 3 letters
   IF old_password = '' THEN
      raise_application_error(-20004, 'Old password is null');
   END IF;

   differ := length(old_password) - length(password);
   IF abs(differ) < 3 THEN
      IF length(password) < length(old_password) THEN
         m := length(password);
      ELSE
         m := length(old_password);
      END IF;
      differ := abs(differ);
      FOR i IN 1..m LOOP
          IF substr(password,i,1) != substr(old_password,i,1) THEN
             differ := differ + 1;
          END IF;
      END LOOP;
      IF differ < 3 THEN
          raise_application_error(-20004, 'Password must differ by at least 3 characters');

      END IF;
   END IF;

   -- Check if the password has 3 consecutive repeating characters
   m := length(password) - 1;
   same_chrs := 1;
   FOR i IN 1..m LOOP
         IF substr(password,i,1) = substr(password,i+1,1)  THEN
            same_chrs := same_chrs + 1;
         ELSE
            same_chrs := 1;
         END IF;

         IF same_chrs = 3 THEN
            EXIT;
         END IF;
   END LOOP;
   IF same_chrs = 3 THEN
          raise_application_error(-20005, 'Password can not contain more than 3consecutive repeating characters');

   END IF;
   -- Everything is fine; return TRUE ;
   RETURN(TRUE);

END;
/