-- Tạo mô hình dữ liệu cho thông tin học sinh
CREATE SCHEMA openlearn;

 CREATE TABLE "openlearn"."assessments"
 (
 code_module varchar(5),
 code_presentation varchar(5),
 id_assessment integer,
 assessment_type varchar(5),
 assessment_date bigint,
 weight decimal(10,2)
 )
 DISTSTYLE AUTO
 SORTKEY AUTO
 ENCODE AUTO;

 CREATE TABLE "openlearn"."courses"
 (
 code_module    varchar(5),            
code_presentation         varchar(5),
 module_presentation_length integer
 )
 DISTSTYLE AUTO
 SORTKEY AUTO
 ENCODE AUTO;

 CREATE TABLE "openlearn"."student_assessment"
 (
 id_assessment  integer,
 id_student     integer,
 date_submitted bigint,
 is_banked      smallint,
 score          smallint,
)
 DISTSTYLE AUTO
 SORTKEY AUTO
 ENCODE AUTO;

 CREATE TABLE "openlearn"."student_info"
 (
 code_module       varchar(5),    
code_presentation     varchar(5),
id_student            integer,
gender                char(1),
region   varchar(50),             
highest_education    varchar(50), 
imd_band              varchar(10),
age_band              varchar(10),
 num_of_prev_atteempts smallint,
 studied_credits       smallint,
disability            char(1),
final_result          varchar(20)
)
 DISTSTYLE AUTO
 SORTKEY AUTO
 ENCODE AUTO;
 
 CREATE TABLE "openlearn"."student_registration"
 (
 code_module   varchar(5),
 code_presendation   varchar(5),
 id_student    integer,
 date_registration   bigint ,
 date_unregistration bigint
 )
 DISTSTYLE AUTO
 SORTKEY AUTO
 ENCODE AUTO;

 CREATE TABLE "openlearn"."student_lms"
 (
 code_module       varchar(5),
 code_presentation varchar(5),
 id_student        integer,
 id_site           integer,
 date              bigint,
sum_click         integer
)
 DISTSTYLE AUTO
 SORTKEY AUTO
 ENCODE AUTO;
 
 CREATE TABLE "openlearn"."lms"
 (
 id_site      integer,
code_module       varchar(5),
 code_presentation varchar(5),
 activity_type     varchar(20),
 week_from         smallint,
week_to           smallint
)
 DISTSTYLE AUTO
 SORTKEY AUTO
 ENCODE AUTO;
-- Load dữ liệu bằng câu lệnh copy
COPY "openlearn"."assessments"
 FROM 's3://openlearn-redshift/assessments'
 iam_role default
 delimiter ',' region 'us-east-1'
 REMOVEQUOTES IGNOREHEADER 1;

 COPY "openlearn"."courses"
 FROM 's3://openlearn-redshift/courses'
 iam_role default
 delimiter ',' region 'us-east-1'
 REMOVEQUOTES IGNOREHEADER 1;

 COPY "openlearn"."student_assessment"
 FROM 's3://openlearn-redshift/studentAssessment'
 iam_role default
 delimiter ',' region 'us-east-1'
 REMOVEQUOTES IGNOREHEADER 1;

 COPY "openlearn"."student_info"
 FROM 's3://openlearn-redshift/studentInfo'
 iam_role default
 delimiter ',' region 'us-east-1'
REMOVEQUOTES IGNOREHEADER 1;

 COPY "openlearn"."student_registration"
 FROM 's3://openlearn-redshift/studentRegistration'
 iam_role default
 delimiter ',' region 'us-east-1'
 REMOVEQUOTES IGNOREHEADER 1;

 COPY "openlearn"."student_lms"
 FROM 's3://openlearn-redshift/studentlms'
 iam_role default
 delimiter ',' region 'us-east-1'
 REMOVEQUOTES IGNOREHEADER 1;

 COPY "openlearn"."lms"
 FROM 's3://openlearn-redshift/lms'
 iam_role default
 delimiter ',' region 'us-east-1'
 REMOVEQUOTES IGNOREHEADER 1;

 -- Tạo 3 bảng dữ liệu và copy từ s3
CREATE TABLE openlearn.course_registration (
    date_registered DATE,
    date_dropped DATE,
    student_id    INTEGER,
    course_id     INTEGER,
    status        VARCHAR(50),
    semester_id   INTEGER,
    update_ts     TIMESTAMP WITH TIME ZONE
);
COPY openlearn.course_registration
FROM 's3://openlearn-redshift/sis/course_registration'
IAM_ROLE default
FORMAT AS PARQUET
REGION 'us-east-1';


CREATE TABLE openlearn.course_outcome (
    student_id     INTEGER,
    course_id      INTEGER,
    semester_id    INTEGER,
    score          FLOAT,
    letter_grade   VARCHAR(5)
);
COPY openlearn.course_outcome
FROM 's3://openlearn-redshift/sis/course_outcome'
IAM_ROLE default
FORMAT AS PARQUET
REGION 'us-east-1';
CREATE TABLE openlearn.course_schedule (
    course_id            BIGINT,
    semester_id          BIGINT,
    staff_id             BIGINT,
    lecture_days         VARCHAR(7),
    lecture_start_hour   INTEGER,
    lecture_duration     INTEGER,
    lab_days             VARCHAR(7),
    lab_start_hour       INTEGER,
    lab_duration         INTEGER
);
COPY openlearn.course_schedule
FROM 's3://openlearn-redshift/sis/course_schedule'
IAM_ROLE default
FORMAT AS PARQUET
REGION 'us-east-1';

--Tạo materialized view

CREATE materialized view mv_course_outcomes_fact AS
 SELECT
 co.student_id,
 co.course_id,
 co.semester_id,
 co.score,
 co.letter_grade,
 cr.date_registered,
 cr.date_dropped,
 cr.status,
 cs.staff_id,
 cs.lecture_days,
 cs.lecture_start_hour,
 cs.lecture_duration,
 cs.lab_days,
 cs.lab_start_hour,
 cs.lab_duration
 FROM openlearn.course_registration cr
 JOIN openlearn.course_outcome co
 ON cr.student_id = co.student_id AND
 cr.course_id = co.course_id AND
 cr.semester_id = co.semester_id
 JOIN openlearn.course_schedule cs
 ON cr.course_id = cs.course_id AND
 cr.semester_id = cs.semester_id;

