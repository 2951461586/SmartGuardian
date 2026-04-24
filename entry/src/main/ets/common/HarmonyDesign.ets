import { getCurrentRolePalette, RolePalette } from './RoleTheme';

export interface HarmonyColorTokens {
  brandBlue: string;
  brandBluePressed: string;
  page: string;
  surface: string;
  surfaceSubtle: string;
  line: string;
  textPrimary: string;
  textSecondary: string;
  textTertiary: string;
  success: string;
  warning: string;
  danger: string;
}

export interface HarmonyRadiusTokens {
  card: number;
  panel: number;
  control: number;
  icon: number;
  pill: number;
}

export interface HarmonySpaceTokens {
  page: number;
  card: number;
  section: number;
  compact: number;
}

export const HarmonyColor: HarmonyColorTokens = {
  brandBlue: '#0A59F7',
  brandBluePressed: '#0646C8',
  page: '#F7F9FC',
  surface: '#FFFFFF',
  surfaceSubtle: '#F3F6FB',
  line: '#E8EEF7',
  textPrimary: '#101828',
  textSecondary: '#667085',
  textTertiary: '#98A2B3',
  success: '#22A06B',
  warning: '#B7791F',
  danger: '#D92D20'
} as HarmonyColorTokens;

export const HarmonyRadius: HarmonyRadiusTokens = {
  card: 24,
  panel: 28,
  control: 16,
  icon: 14,
  pill: 999
} as HarmonyRadiusTokens;

export const HarmonySpace: HarmonySpaceTokens = {
  page: 16,
  card: 18,
  section: 14,
  compact: 8
} as HarmonySpaceTokens;

export function harmonyShadowColor(): string {
  return '#18233F12';
}

export function harmonySoftGradient(rolePalette?: RolePalette): LinearGradient {
  const palette = rolePalette ?? getCurrentRolePalette();
  return {
    angle: 135,
    colors: [['#FFFFFF', 0], [palette.gradientStart, 0.62], [palette.gradientEnd, 1]]
  };
}

export function harmonyHeroGradient(rolePalette?: RolePalette): LinearGradient {
  const palette = rolePalette ?? getCurrentRolePalette();
  return {
    angle: 130,
    colors: [[palette.primary, 0], [palette.primaryDark, 0.62], ['#1F2A44', 1]]
  };
}
