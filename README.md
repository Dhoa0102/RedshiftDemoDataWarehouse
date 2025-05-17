# RedshiftDemoDataWarehouse
Demo AWS Redshift
1.	Tạo Redshift serverless

 ![image](https://github.com/user-attachments/assets/e4871f65-ee85-4564-af09-e1df7c7d0239)
![image](https://github.com/user-attachments/assets/d2b41b12-1c96-4386-afe8-35012a895d33)

 
2.	Thiết lập mô hình dữ liệu và nhập dữ liệu
Tập dữ liệu The Open University Learning Analytics Dataset (OULAD)
Bộ dữ liệu chứa dữ liệu về các khóa học, sinh viên và tương tác của họ với Môi trường học tập ảo trực tuyến (VLE) cho bảy khóa học được chọn, được gọi là các mô-đun. Bộ dữ liệu giả định rằng có hai học kỳ mỗi năm và các khóa học bắt đầu vào tháng 2 và tháng 10 hàng năm. Học kỳ của khóa học được xác định bằng cột code_presentation trong bảng khóa học và các mô-đun mã được thêm chữ cái “B” và “J” tương ứng, với một năm gồm bốn chữ số làm tiền tố. Bộ dữ liệu bao gồm các bảng được kết nối bằng các mã định danh duy nhất . Tất cả các bảng đều được lưu trữ ở định dạng CSV. Mô hình dữ liệu bao gồm bảy bảng, với dữ liệu liên quan đến học sinh, mô-đun, và hoạt động.
 
![image](https://github.com/user-attachments/assets/cdf4413c-1d47-449a-a0f2-ee37d9e18611)
![image](https://github.com/user-attachments/assets/8887e642-d266-49e1-bbc9-03e8ed2d8caa)

 
Tạo mô hình dữ liệu cho thông tin học sinh
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
 ![image](https://github.com/user-attachments/assets/7d34b898-faed-48cd-a3b7-4f987c4f8d44)

Load dữ liệu bằng câu lệnh copy
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
![image](https://github.com/user-attachments/assets/346cf93b-df6c-4c51-91e1-32692ae3f96b)
![image](https://github.com/user-attachments/assets/644a0cd2-2267-444e-bc9c-c9956eefe5ae)


 
 
Tạo star-schema
Tạo 3 bảng dữ liệu và copy từ s3
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

Tạo materialized view

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
Star schema
Đo lường kết quả học tập
 ![image](https://github.com/user-attachments/assets/4516666c-0e60-411e-98dc-4a86eed4905b)

Tìm số học sinh đạt được mỗi lớp 
SELECT semester_id, course_id, letter_grade, count(*) FROM openlearn.mv_course_outcomes_fact GROUP BY semester_id, course_id, letter_grade;
 
![image](https://github.com/user-attachments/assets/d34506dd-5a8a-412c-92d4-08082306aef2)

3.	Thu thập tập tin liên tục từ Amazon S3
Cấu hình policy cho IAM role, redshift
Tạo S3 event integrations
 ![image](https://github.com/user-attachments/assets/882f83d3-d1e4-413b-871c-0b136a894d96)

Tạo job tự động copy dữ liệu từ s3
COPY openlearn.course_schedule
FROM 's3://demodatawarehouses3/course_schedule/'
IAM_ROLE 'arn:aws:iam::727646483587:role/service-role/AmazonRedshift-CommandsAccessRole-20250411T224229'
FORMAT AS PARQUET
JOB CREATE copy_course_schedule
AUTO ON;

![image](https://github.com/user-attachments/assets/14dab948-6790-4767-b52f-45d3535d91b5)

 
Ngoài ra có thể lên lịch chạy câu lệnh truy vấn thay cho thu thập tập tin liên tục
 
 
 ![image](https://github.com/user-attachments/assets/3b815ade-6307-476f-bcce-a44981106590)
![image](https://github.com/user-attachments/assets/7d743807-5a4c-4b71-863b-c27ae140a830)
![image](https://github.com/user-attachments/assets/6eff24ae-b821-4d3c-9b19-a770854882bd)
![image](https://github.com/user-attachments/assets/4b6b7777-faf2-4045-9a63-27c02b4d2653)
![image](https://github.com/user-attachments/assets/0376f0ee-a0d7-4fa3-ae4a-671e8c06b60f)
![image](https://github.com/user-attachments/assets/6ee9e7e3-cf21-4feb-aedc-a7f7fdf7a549)

 
 
 
4.	ETL bằng AWS GLUE
Tạo connection
Tạo kết nối giữa redshift, glue và s3 thông qua VPC, enpoint, IAM role
Trước hết thêm các policy cho IAM role, tạo endpoint, tùy chỉnh security group rồi mới tạo connection
 ![image](https://github.com/user-attachments/assets/d83067fe-5912-4ea1-a7f3-f136770e3b18)
![image](https://github.com/user-attachments/assets/aec1ea5c-715c-4a52-bae7-58a2f1e74e84)
![image](https://github.com/user-attachments/assets/371c774b-bf29-435e-ba1b-fc5bf197fcc8)

  
Tạo AWS Glue job
 ![image](https://github.com/user-attachments/assets/d6dc66f0-6311-49ac-8f88-bbed4c6cc049)
![image](https://github.com/user-attachments/assets/dc224243-4506-418d-afdb-4b2b7bfda6ce)
 ![image](https://github.com/user-attachments/assets/a2a7b573-12fb-4b49-8347-d9b2be52f0ea)
![image](https://github.com/user-attachments/assets/9f5b6a22-dbbf-4cd2-946d-a3e22784bc37)
![image](https://github.com/user-attachments/assets/481e376c-cc0e-4218-81b7-bee2e92be67b)
![image](https://github.com/user-attachments/assets/16d24f09-a845-4583-b15a-4c3286f2486f)
![image](https://github.com/user-attachments/assets/d9ae04e1-d798-4eda-b7a7-a407a7977932)

 
 
 
 
 






















