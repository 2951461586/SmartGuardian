import { HarmonyColor, HarmonyReport, harmonyShadowColor } from '../../common/HarmonyDesign';
import { getCurrentRolePalette } from '../../common/RoleTheme';

@Component
export struct FormSurface {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop illustration: ResourceStr = '';
  @Prop maxWidth: number = 560;
  @BuilderParam content?: () => void = this.emptyBuilder;

  @Builder
  emptyBuilder() {}

  build() {
    Column() {
      if (this.illustration) {
        Image(this.illustration)
          .width('100%')
          .height(160)
          .objectFit(ImageFit.Cover)
          .borderRadius(28)
      }

      if (this.title) {
        Text(this.title)
          .width('100%')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: this.illustration ? 18 : 0 })
      }

      if (this.subtitle) {
        Text(this.subtitle)
          .width('100%')
          .fontSize(14)
          .lineHeight(22)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8, bottom: 18 })
      }

      if (this.content) {
        this.content()
      }
    }
    .width('100%')
    .constraintSize({ maxWidth: this.maxWidth })
    .padding(24)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(34)
    .border({
      width: 1,
      color: $r('app.color.divider'),
      radius: 34,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 20,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 10
    })
  }
}

@Component
export struct FormTextField {
  @Prop icon: Resource = $r('app.media.ic_user');
  @Prop label: string = '';
  @Prop placeholder: string = '';
  @Prop text: string = '';
  @Prop keyboardType: InputType = InputType.Normal;
  onChange?: (value: string) => void;

  build() {
    Column() {
      if (this.label) {
        Text(this.label)
          .width('100%')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_secondary'))
          .margin({ bottom: 8 })
      }

      Row() {
        this.buildIconShell()

        TextInput({
          placeholder: this.placeholder,
          text: this.text
        })
          .layoutWeight(1)
          .height(56)
          .fontSize(16)
          .backgroundColor(HarmonyColor.surface)
          .type(this.keyboardType)
          .margin({ left: 12 })
          .onChange((value: string) => {
            if (this.onChange) {
              this.onChange(value);
            }
          })
      }
      .width('100%')
      .padding({ left: 14, right: 14 })
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(22)
      .border({
        width: 1,
        color: $r('app.color.divider'),
        radius: 22,
        style: BorderStyle.Solid
      })
    }
  }

  @Builder
  private buildIconShell() {
    Column() {
      Image(this.icon)
        .width(18)
        .height(18)
        .objectFit(ImageFit.Contain)
        .fillColor(getCurrentRolePalette().primary)
    }
    .width(36)
    .height(36)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(getCurrentRolePalette().light)
    .borderRadius(14)
  }
}

@Component
export struct FormSecureField {
  @Prop icon: Resource = $r('app.media.ic_lock');
  @Prop label: string = '';
  @Prop placeholder: string = '';
  @Prop text: string = '';
  @State isVisible: boolean = false;
  onChange?: (value: string) => void;

  build() {
    Column() {
      if (this.label) {
        Text(this.label)
          .width('100%')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_secondary'))
          .margin({ bottom: 8 })
      }

      Row() {
        this.buildIconShell()

        TextInput({
          placeholder: this.placeholder,
          text: this.text
        })
          .layoutWeight(1)
          .height(56)
          .fontSize(16)
          .backgroundColor(HarmonyColor.surface)
          .type(this.isVisible ? InputType.Normal : InputType.Password)
          .margin({ left: 12 })
          .onChange((value: string) => {
            if (this.onChange) {
              this.onChange(value);
            }
          })

        Button(this.isVisible ? '隐藏' : '显示')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(getCurrentRolePalette().primary)
          .backgroundColor(HarmonyColor.surface)
          .onClick(() => {
            this.isVisible = !this.isVisible;
          })
      }
      .width('100%')
      .padding({ left: 14, right: 10 })
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(22)
      .border({
        width: 1,
        color: $r('app.color.divider'),
        radius: 22,
        style: BorderStyle.Solid
      })
    }
  }

  @Builder
  private buildIconShell() {
    Column() {
      Image(this.icon)
        .width(18)
        .height(18)
        .objectFit(ImageFit.Contain)
        .fillColor(getCurrentRolePalette().primary)
    }
    .width(36)
    .height(36)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(getCurrentRolePalette().light)
    .borderRadius(14)
  }
}

@Component
export struct FormNoticeStrip {
  @Prop message: string = '';
  @Prop toneColor: ResourceColor = $r('app.color.primary');
  @Prop backgroundColorValue: ResourceColor = $r('app.color.primary_light');

  build() {
    if (this.message) {
      Row() {
        Image($r('app.media.ic_info'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain)
          .fillColor(this.toneColor)

        Text(this.message)
          .layoutWeight(1)
          .fontSize(12)
          .lineHeight(18)
          .fontColor(this.toneColor)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .backgroundColor(this.backgroundColorValue)
      .borderRadius(18)
    }
  }
}

@Component
export struct FormSegmentSelector {
  @Prop options: string[] = [];
  @Prop labels: string[] = [];
  @Prop selectedValue: string = '';
  onSelect?: (value: string) => void;

  build() {
    Row() {
      ForEach(this.options, (option: string, index: number) => {
        Button(this.getLabel(index))
          .layoutWeight(1)
          .height(46)
          .fontSize(14)
          .fontWeight(this.selectedValue === option ? FontWeight.Medium : FontWeight.Normal)
          .fontColor(this.selectedValue === option ? HarmonyColor.textInverse : $r('app.color.text_secondary'))
          .backgroundColor(this.selectedValue === option ? getCurrentRolePalette().primary : HarmonyColor.surfaceSubtle)
          .borderRadius(18)
          .border({
            width: 1,
            color: this.selectedValue === option ? getCurrentRolePalette().primary : $r('app.color.divider'),
            radius: 18,
            style: BorderStyle.Solid
          })
          .margin({ left: index === 0 ? 0 : 8 })
          .onClick(() => {
            if (this.onSelect) {
              this.onSelect(option);
            }
          })
      }, (option: string) => option)
    }
    .width('100%')
  }

  private getLabel(index: number): string {
    if (index < this.labels.length) {
      return this.labels[index];
    }
    return this.options[index];
  }
}

@Component
export struct FormActionBar {
  @Prop primaryText: string = '';
  @Prop secondaryText: string = '';
  @Prop helperText: string = '';
  @Prop errorText: string = '';
  @Prop primaryEnabled: boolean = true;
  @Prop loading: boolean = false;
  onPrimary?: () => void;
  onSecondary?: () => void;

  build() {
    Column() {
      if (this.helperText) {
        FormNoticeStrip({
          message: this.helperText
        })
          .margin({ bottom: 12 })
      }

      if (this.errorText) {
        FormNoticeStrip({
          message: this.errorText,
          toneColor: $r('app.color.error'),
          backgroundColorValue: HarmonyReport.dangerSurface
        })
          .margin({ bottom: 12 })
      }

      Button() {
        if (this.loading) {
          LoadingProgress()
            .width(18)
            .height(18)
            .color(HarmonyColor.textInverse)
        } else {
          Text(this.primaryText)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(HarmonyColor.textInverse)
        }
      }
      .width('100%')
      .height(54)
      .enabled(this.primaryEnabled && !this.loading)
      .backgroundColor(getCurrentRolePalette().primary)
      .borderRadius(24)
      .onClick(() => {
        if (this.onPrimary) {
          this.onPrimary();
        }
      })

      if (this.secondaryText) {
        Button(this.secondaryText)
          .width('100%')
          .height(48)
          .fontSize(14)
          .fontColor(getCurrentRolePalette().primary)
          .backgroundColor(HarmonyColor.surface)
          .margin({ top: 12 })
          .onClick(() => {
            if (this.onSecondary) {
              this.onSecondary();
            }
          })
      }
    }
    .width('100%')
  }
}
