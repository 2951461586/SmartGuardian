import { UserRole } from '../../../models/common';
import { GuardianRelation, Student, UserInfo } from '../../../models/user';

export const mockUsers: UserInfo[] = [
  {
    id: 1,
    username: 'parent_zhang',
    realName: '张丽',
    mobile: '13800000001',
    roleType: UserRole.PARENT,
    avatar: 'https://example.com/avatar/parent_zhang.jpg'
  },
  {
    id: 2,
    username: 'teacher_wang',
    realName: '王老师',
    mobile: '13800000002',
    roleType: UserRole.TEACHER,
    avatar: 'https://example.com/avatar/teacher_wang.jpg'
  },
  {
    id: 3,
    username: 'admin_li',
    realName: '李管理员',
    mobile: '13800000003',
    roleType: UserRole.ORG_ADMIN,
    avatar: 'https://example.com/avatar/admin_li.jpg'
  }
];

export const mockStudents: Student[] = [
  {
    id: 1,
    studentNo: 'S20260001',
    name: '王小明',
    schoolId: 1,
    schoolName: '实验小学',
    classId: 1,
    className: '三年级1班',
    grade: '三年级',
    gender: 'MALE',
    birthDate: '2016-05-15',
    guardianUserId: 1,
    guardianName: '张丽',
    guardianMobile: '13800000001',
    healthNotes: '无特殊病史',
    status: 'ACTIVE',
    createdAt: '2024-01-01T00:00:00Z',
    updatedAt: '2024-01-01T00:00:00Z'
  },
  {
    id: 2,
    studentNo: 'S20260002',
    name: '李小红',
    schoolId: 1,
    schoolName: '实验小学',
    classId: 1,
    className: '三年级1班',
    grade: '三年级',
    gender: 'FEMALE',
    birthDate: '2016-08-20',
    guardianUserId: 1,
    guardianName: '张丽',
    guardianMobile: '13800000001',
    healthNotes: '对花生过敏',
    status: 'ACTIVE',
    createdAt: '2024-01-01T00:00:00Z',
    updatedAt: '2024-01-01T00:00:00Z'
  }
];

export const mockGuardians: GuardianRelation[] = [
  {
    id: 1,
    studentId: 1,
    userId: 1,
    relation: 'MOTHER',
    isPrimary: true,
    authorizedPickup: true,
    pickupCode: 'PICKUP-1001'
  },
  {
    id: 2,
    studentId: 1,
    userId: 2,
    relation: 'FATHER',
    isPrimary: false,
    authorizedPickup: true,
    pickupCode: 'PICKUP-1002'
  }
];
