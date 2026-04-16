-- 学生智慧托管系统初始化测试数据
-- 执行前请先完成 docs/数据库建表SQL.sql 建表

USE smart_guardian;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 清理测试数据（按依赖顺序）
DELETE FROM `payment_record`;
DELETE FROM `student_timeline`;
DELETE FROM `message_record`;
DELETE FROM `homework_feedback`;
DELETE FROM `homework_task`;
DELETE FROM `attendance_record`;
DELETE FROM `session_schedule`;
DELETE FROM `order_info`;
DELETE FROM `guardian_relation`;
DELETE FROM `student`;
DELETE FROM `service_product`;
DELETE FROM `user`;

ALTER TABLE `user` AUTO_INCREMENT = 1;
ALTER TABLE `student` AUTO_INCREMENT = 1;
ALTER TABLE `guardian_relation` AUTO_INCREMENT = 1;
ALTER TABLE `service_product` AUTO_INCREMENT = 1;
ALTER TABLE `order_info` AUTO_INCREMENT = 1;
ALTER TABLE `session_schedule` AUTO_INCREMENT = 1;
ALTER TABLE `attendance_record` AUTO_INCREMENT = 1;
ALTER TABLE `homework_task` AUTO_INCREMENT = 1;
ALTER TABLE `homework_feedback` AUTO_INCREMENT = 1;
ALTER TABLE `message_record` AUTO_INCREMENT = 1;
ALTER TABLE `student_timeline` AUTO_INCREMENT = 1;
ALTER TABLE `payment_record` AUTO_INCREMENT = 1;

-- 1. 初始化用户
INSERT INTO `user` (`id`, `account_no`, `username`, `password_hash`, `real_name`, `mobile`, `role_type`, `status`, `last_login_time`) VALUES
(1, 'U20260001', 'parent_zhang', '$2a$10$demoHashParent001', '张丽', '13800000001', 'PARENT', 'ENABLED', '2026-04-16 08:10:00'),
(2, 'U20260002', 'parent_li', '$2a$10$demoHashParent002', '李强', '13800000002', 'PARENT', 'ENABLED', '2026-04-16 08:20:00'),
(3, 'U20260003', 'teacher_wang', '$2a$10$demoHashTeacher001', '王老师', '13800000003', 'TEACHER', 'ENABLED', '2026-04-16 07:50:00'),
(4, 'U20260004', 'teacher_zhao', '$2a$10$demoHashTeacher002', '赵老师', '13800000004', 'TEACHER', 'ENABLED', '2026-04-16 07:55:00'),
(5, 'U20260005', 'org_admin', '$2a$10$demoHashOrg001', '机构管理员', '13800000005', 'ORG_ADMIN', 'ENABLED', '2026-04-16 07:30:00'),
(6, 'U20260006', 'school_admin', '$2a$10$demoHashSchool001', '学校管理员', '13800000006', 'SCHOOL_ADMIN', 'ENABLED', '2026-04-16 07:25:00'),
(7, 'U20260007', 'finance_user', '$2a$10$demoHashFinance001', '财务人员', '13800000007', 'FINANCE', 'ENABLED', '2026-04-16 09:00:00'),
(8, 'U20260008', 'platform_admin', '$2a$10$demoHashPlatform001', '平台管理员', '13800000008', 'PLATFORM_ADMIN', 'ENABLED', '2026-04-16 09:10:00');

-- 2. 初始化学生
INSERT INTO `student` (`id`, `student_no`, `name`, `gender`, `birthday`, `school_id`, `class_id`, `grade`, `guardian_user_id`, `health_notes`, `status`) VALUES
(1, 'S20260001', '张小明', '男', '2015-09-01', 101, 1001, '三年级', 1, '花生轻微过敏', 'ACTIVE'),
(2, 'S20260002', '李小雨', '女', '2014-03-15', 101, 1002, '四年级', 2, '无', 'ACTIVE');

-- 3. 初始化监护关系
INSERT INTO `guardian_relation` (`id`, `student_id`, `user_id`, `relation_type`, `is_primary`, `pickup_auth_level`, `status`) VALUES
(1, 1, 1, '母亲', 1, 'FULL', 'ACTIVE'),
(2, 2, 2, '父亲', 1, 'FULL', 'ACTIVE');

-- 4. 初始化托管服务产品
INSERT INTO `service_product` (`id`, `service_name`, `service_type`, `org_id`, `school_scope`, `grade_scope`, `start_time`, `end_time`, `capacity`, `price`, `refund_rule`, `status`) VALUES
(1, '课后作业辅导班', 'HOMEWORK', 201, '实验小学', '三年级,四年级,五年级', '16:30:00', '18:30:00', 30, 800.00, '开班前一天可全额退款', 'ENABLED'),
(2, '晚托看护班', 'CARE', 201, '实验小学', '一年级,二年级,三年级,四年级', '18:30:00', '20:00:00', 25, 600.00, '开班前一天可退80%', 'ENABLED');

-- 5. 初始化订单
INSERT INTO `order_info` (`id`, `order_no`, `student_id`, `guardian_user_id`, `service_product_id`, `order_status`, `amount`, `paid_amount`, `pay_status`, `audit_status`, `start_date`, `end_date`) VALUES
(1, 'O202604160001', 1, 1, 1, 'ACTIVE', 800.00, 800.00, 'PAID', 'APPROVED', '2026-04-01', '2026-04-30'),
(2, 'O202604160002', 2, 2, 1, 'ACTIVE', 800.00, 800.00, 'PAID', 'APPROVED', '2026-04-01', '2026-04-30');

-- 6. 初始化班次
INSERT INTO `session_schedule` (`id`, `org_id`, `service_product_id`, `teacher_user_id`, `classroom_id`, `session_date`, `start_time`, `end_time`, `capacity`, `current_count`, `status`) VALUES
(1, 201, 1, 3, 301, '2026-04-16', '16:30:00', '18:30:00', 30, 2, 'PLANNED'),
(2, 201, 2, 4, 302, '2026-04-16', '18:30:00', '20:00:00', 25, 0, 'PLANNED');

-- 7. 初始化考勤
INSERT INTO `attendance_record` (`id`, `student_id`, `order_id`, `attendance_date`, `session_id`, `sign_in_time`, `sign_in_type`, `sign_in_location`, `sign_out_time`, `sign_out_type`, `sign_out_guardian_id`, `status`, `abnormal_flag`, `abnormal_type`, `operator_user_id`) VALUES
(1, 1, 1, '2026-04-16', 1, '2026-04-16 16:35:00', 'QRCODE', '实验小学托管教室A', '2026-04-16 18:32:00', 'PARENT_PICKUP', 1, 'SIGNED_OUT', 0, NULL, 3),
(2, 2, 2, '2026-04-16', 1, '2026-04-16 16:48:00', 'FACE', '实验小学托管教室A', NULL, NULL, NULL, 'SIGNED_IN', 1, 'LATE', 3);

-- 8. 初始化作业任务
INSERT INTO `homework_task` (`id`, `student_id`, `subject`, `title`, `content`, `source_type`, `task_date`, `due_time`, `status`, `created_by`) VALUES
(1, 1, '语文', '三年级语文作业', '完成课后练习第12页，抄写生字2遍', 'SCHOOL_SYNC', '2026-04-16', '2026-04-16 20:00:00', 'COMPLETED', 3),
(2, 1, '数学', '三年级数学作业', '完成口算练习和应用题3道', 'SCHOOL_SYNC', '2026-04-16', '2026-04-16 20:00:00', 'IN_PROGRESS', 3),
(3, 2, '英语', '四年级英语作业', '背诵Unit 3 单词并完成练习册', 'SCHOOL_SYNC', '2026-04-16', '2026-04-16 20:00:00', 'IN_PROGRESS', 4);

-- 9. 初始化作业反馈
INSERT INTO `homework_feedback` (`id`, `homework_task_id`, `student_id`, `teacher_user_id`, `progress_rate`, `feedback_text`, `performance_tags`, `attachment_urls`, `parent_confirm_status`) VALUES
(1, 1, 1, 3, 100, '语文作业已完成，书写较工整，需注意个别字笔顺。', '认真,书写工整', 'https://example.com/files/homework/zhangxiaoming-yuwen-20260416.jpg', 'CONFIRMED'),
(2, 2, 1, 3, 60, '数学应用题理解稍慢，已进行一对一讲解。', '需加强,专注', 'https://example.com/files/homework/zhangxiaoming-math-20260416.jpg', 'UNCONFIRMED'),
(3, 3, 2, 4, 50, '英语单词掌握一般，建议家长晚上再陪读10分钟。', '需复习', 'https://example.com/files/homework/lixiaoyu-english-20260416.jpg', 'UNCONFIRMED');

-- 10. 初始化消息记录
INSERT INTO `message_record` (`id`, `sender_user_id`, `receiver_user_id`, `conversation_id`, `msg_type`, `content`, `biz_type`, `read_status`, `sent_at`) VALUES
(1, 3, 1, 10001, 'TEXT', '张小明已于16:35到达托管教室，请家长放心。', 'ATTENDANCE_NOTICE', 'READ', '2026-04-16 16:36:00'),
(2, 3, 1, 10001, 'TEXT', '数学作业正在辅导中，稍后会同步照片。', 'HOMEWORK_NOTICE', 'UNREAD', '2026-04-16 17:20:00'),
(3, 4, 2, 10002, 'TEXT', '李小雨今日签到稍晚，已正常进入托管班。', 'ABNORMAL_ALERT', 'UNREAD', '2026-04-16 16:50:00');

-- 11. 初始化动态时间线
INSERT INTO `student_timeline` (`id`, `student_id`, `biz_date`, `event_type`, `event_title`, `event_detail`, `related_biz_id`, `visibility_scope`, `created_by`) VALUES
(1, 1, '2026-04-16', 'SIGN_IN', '已签到', '张小明于16:35通过二维码签到进入托管教室A。', 1, 'PARENT', 3),
(2, 1, '2026-04-16', 'HOMEWORK', '完成语文作业', '已完成语文课后练习及生字抄写。', 1, 'PARENT', 3),
(3, 1, '2026-04-16', 'SIGN_OUT', '已签退', '张小明于18:32由母亲接回。', 1, 'PARENT', 3),
(4, 2, '2026-04-16', 'ABNORMAL', '签到迟到预警', '李小雨于16:48签到，超过预设签到时间阈值。', 2, 'PARENT', 4);

-- 12. 初始化支付流水
INSERT INTO `payment_record` (`id`, `order_id`, `payment_no`, `pay_channel`, `pay_amount`, `pay_status`, `refund_amount`, `refund_status`, `transaction_time`, `callback_time`) VALUES
(1, 1, 'P202604160001', 'WECHAT_PAY', 800.00, 'SUCCESS', 0.00, 'NONE', '2026-04-01 10:00:00', '2026-04-01 10:00:05'),
(2, 2, 'P202604160002', 'ALIPAY', 800.00, 'SUCCESS', 0.00, 'NONE', '2026-04-01 10:10:00', '2026-04-01 10:10:03');

SET FOREIGN_KEY_CHECKS = 1;
