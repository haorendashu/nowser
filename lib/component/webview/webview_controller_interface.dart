
abstract class WebviewControllerInterface {

  Future<void> reload();

  Future<void> goBack();

  Future<bool> canGoBack();

  Future<void> goForward();

  Future<Uri?> getUrl();

  Future<String?> getFavicon();

  Future<void> loadUrl(String url);

  Future<String?> getTitle();

}