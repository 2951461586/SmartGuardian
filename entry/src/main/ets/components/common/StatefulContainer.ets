import { EmptyType, EmptyState } from './EmptyState';
import { ErrorState, ErrorStateType } from './ErrorState';
import { LoadingSize, LoadingState } from './LoadingState';

export enum ViewState {
  CONTENT = 'CONTENT',
  LOADING = 'LOADING',
  EMPTY = 'EMPTY',
  ERROR = 'ERROR'
}

@Component
export struct StatefulContainer {
  @Prop state: ViewState = ViewState.CONTENT;
  @Prop loadingMessage: string = '';
  @Prop loadingSize: LoadingSize = LoadingSize.DEFAULT;
  @Prop fullHeight: boolean = false;
  @Prop emptyType: EmptyType = EmptyType.DEFAULT;
  @Prop emptyTitle: string = '';
  @Prop emptyDescription: string = '';
  @Prop emptyActionText: string = '';
  @Prop errorType: ErrorStateType = ErrorStateType.NETWORK;
  @Prop errorMessage: string = '';
  @Prop retryText: string = '重试';
  onRetry?: () => void;
  onEmptyAction?: () => void;
  @BuilderParam content: () => void = this.emptyBuilder;

  @Builder
  emptyBuilder() {}

  build() {
    Column() {
      if (this.state === ViewState.LOADING) {
        LoadingState({
          loadingSize: this.loadingSize,
          message: this.loadingMessage,
          fullscreen: false
        })
      } else if (this.state === ViewState.EMPTY) {
        EmptyState({
          type: this.emptyType,
          customTitle: this.emptyTitle,
          customDescription: this.emptyDescription,
          actionText: this.emptyActionText,
          onAction: this.onEmptyAction
        })
      } else if (this.state === ViewState.ERROR) {
        ErrorState({
          type: this.errorType,
          message: this.errorMessage,
          retryText: this.retryText,
          onRetry: this.onRetry
        })
      } else {
        this.content()
      }
    }
    .width('100%')
    .height(this.fullHeight ? '100%' : 'auto')
    .justifyContent(this.state === ViewState.CONTENT ? FlexAlign.Start : FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
