import { getCurrentRolePalette, RolePalette } from './RoleTheme';

export interface HarmonyColorTokens {
  brandBlue: string;
  brandBluePressed: string;
  clear: string;
  page: string;
  surface: string;
  surfaceSubtle: string;
  surfaceMuted: string;
  line: string;
  lineStrong: string;
  textPrimary: string;
  textSecondary: string;
  textTertiary: string;
  textInverse: string;
  textInverseStrong: string;
  textInverseMuted: string;
  success: string;
  warning: string;
  danger: string;
  info: string;
  focus: string;
  overlaySoft: string;
  overlayInverseSoft: string;
  overlayInverseBorder: string;
  overlaySurface: string;
  inkStrong: string;
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
  roomy: number;
}

export interface HarmonyReportTokens {
  positive: string;
  positiveSurface: string;
  caution: string;
  cautionSurface: string;
  accent: string;
  accentSurface: string;
  danger: string;
  dangerSurface: string;
}

export const HarmonyColor: HarmonyColorTokens = {
  brandBlue: '#0A59F7',
  brandBluePressed: '#0646C8',
  clear: '#FFFFFF00',
  page: '#F7F9FC',
  surface: '#FFFFFF',
  surfaceSubtle: '#F3F6FB',
  surfaceMuted: '#EDF2F8',
  line: '#E8EEF7',
  lineStrong: '#D7E0EC',
  textPrimary: '#101828',
  textSecondary: '#667085',
  textTertiary: '#98A2B3',
  textInverse: '#F8FAFC',
  textInverseStrong: '#FFFFFFD9',
  textInverseMuted: '#FFFFFFB8',
  success: '#22A06B',
  warning: '#B7791F',
  danger: '#D92D20',
  info: '#0A59F7',
  focus: '#0A59F7',
  overlaySoft: '#18233F12',
  overlayInverseSoft: '#FFFFFF20',
  overlayInverseBorder: '#FFFFFF2A',
  overlaySurface: '#FFFFFFC9',
  inkStrong: '#18233F'
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
  compact: 8,
  roomy: 24
} as HarmonySpaceTokens;

export const HarmonyReport: HarmonyReportTokens = {
  positive: '#2F9B52',
  positiveSurface: '#EEF6F0',
  caution: '#F2994A',
  cautionSurface: '#FFF4E8',
  accent: '#4F7CFF',
  accentSurface: '#EEF4FF',
  danger: '#E25B5B',
  dangerSurface: '#FFF0F1'
} as HarmonyReportTokens;

export function harmonyShadowColor(): string {
  return HarmonyColor.overlaySoft;
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

export function harmonySoftPanelColor(): string {
  return HarmonyColor.surfaceSubtle;
}

export function harmonyMutedPanelColor(): string {
  return HarmonyColor.surfaceMuted;
}
