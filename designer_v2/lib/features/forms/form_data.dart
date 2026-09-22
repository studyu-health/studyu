typedef FormDataID = String;

abstract class IFormData() {
  FormDataID get id;
  IFormData copy();
}
