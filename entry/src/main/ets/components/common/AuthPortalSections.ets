import { HarmonyColor } from '../../common/HarmonyDesign';
import { Card } from './Card';

export interface PortalOption {
  value: string;
  label: string;
  description: string;
}

@Component
export struct PortalSelectorCard {
  @Prop options: PortalOption[] = [];
  @Prop selectedValue: string = '';
  @Prop hintText: string = '';
  onSelect?: (value: string) => void;

  build() {
    Card({
      title: '选择入口',
      subtitle: '登录前先确认当前使用的是家长、教师还是机构入口。',
      content: this.buildCardContent
    })
  }

  @Builder
  private buildCardContent() {
    Column() {
      Row() {
        ForEach(this.options, (option: PortalOption, index: number) => {
          Button(option.label)
            .layoutWeight(1)
            .height(42)
            .fontSize(14)
            .fontWeight(this.selectedValue === option.value ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.selectedValue === option.value ? HarmonyColor.textInverse : $r('app.color.text_secondary'))
            .backgroundColor(this.selectedValue === option.value ? $r('app.color.primary') : $r('app.color.card_background'))
            .borderRadius(14)
            .border({
              width: 1,
              color: this.selectedValue === option.value ? $r('app.color.primary') : HarmonyColor.line,
              radius: 14,
              style: BorderStyle.Solid
            })
            .margin({ left: index === 0 ? 0 : 8 })
            .onClick(() => {
              if (this.onSelect) {
                this.onSelect(option.value);
              }
            })
        }, (option: PortalOption) => option.value)
      }
      .width('100%')

      if (this.hintText) {
        Text(this.hintText)
          .width('100%')
          .fontSize(13)
          .lineHeight(20)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 12 })
      }
    }
    .width('100%')
  }
}

@Component
export struct EnvironmentSelectorCard {
  @Prop currentEnv: string = '';
  @Prop mockEnvValue: string = '';
  @Prop agcEnvValue: string = '';
  @Prop apiBaseUrl: string = '';
  @Prop showUrlInput: boolean = false;
  @Prop urlPlaceholder: string = '';
  @Prop helperText: string = '';
  onEnvChange?: (env: string) => void;
  onUrlChange?: (value: string) => void;

  build() {
    Card({
      title: '运行环境',
      subtitle: '登录前可在 Mock 演示和 AGC 网关之间切换。',
      content: this.buildCardContent
    })
  }

  @Builder
  private buildCardContent() {
    Column() {
      Row() {
        this.buildEnvButton('Mock', this.mockEnvValue)
        this.buildEnvButton('AGC', this.agcEnvValue)
      }
      .width('100%')

      if (this.showUrlInput) {
        TextInput({
          placeholder: this.urlPlaceholder,
          text: this.apiBaseUrl
        })
          .width('100%')
          .height(52)
          .fontSize(15)
          .padding({ left: 14, right: 14 })
          .backgroundColor(HarmonyColor.surface)
          .borderRadius(16)
          .border({
            width: 1,
            color: HarmonyColor.line,
            radius: 16,
            style: BorderStyle.Solid
          })
          .margin({ top: 12 })
          .onChange((value: string) => {
            if (this.onUrlChange) {
              this.onUrlChange(value);
            }
          })
      } else if (this.helperText) {
        Text(this.helperText)
          .width('100%')
          .fontSize(12)
          .lineHeight(18)
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 12 })
      }
    }
    .width('100%')
  }

  @Builder
  private buildEnvButton(label: string, env: string) {
    Button(label)
      .layoutWeight(1)
      .height(38)
      .fontSize(13)
      .fontColor(this.currentEnv === env ? HarmonyColor.textInverse : $r('app.color.text_secondary'))
      .backgroundColor(this.currentEnv === env ? $r('app.color.primary') : HarmonyColor.surface)
      .borderRadius(12)
      .margin({ left: label === 'Mock' ? 0 : 8 })
      .onClick(() => {
        if (this.onEnvChange) {
          this.onEnvChange(env);
        }
      })
  }
}
