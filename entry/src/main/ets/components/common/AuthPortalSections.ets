import { HarmonyColor } from '../../common/HarmonyDesign';

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
    Column() {
      Text('选择入口')
        .width('100%')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Text('请选择家长、教师或机构管理入口。')
        .width('100%')
        .fontSize($r('app.float.text_secondary_size'))
        .lineHeight(20)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 6, bottom: 14 })

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

      if (this.hintText.length > 0) {
        Text(this.hintText)
          .width('100%')
          .fontSize(13)
          .lineHeight(20)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(20)
    .border({
      width: 1,
      color: $r('app.color.divider'),
      radius: 20,
      style: BorderStyle.Solid
    })
    .margin({ bottom: 12 })
  }
}
