package ui.mangerUI.userManagerUI;

import RMIModule.BLInterfaces;
import beans.UserManageInfo;
import bl.UserLogic;
import exception.ObjectExistedException;
import exception.ObjectNotFoundException;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.geometry.Pos;
import javafx.scene.control.*;
import javafx.scene.control.cell.CheckBoxTableCell;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.input.MouseButton;
import javafx.scene.input.MouseEvent;
import javafx.util.Callback;
import starter.MainUI;
import util.UserType;

import java.net.URL;
import java.rmi.RemoteException;
import java.util.ArrayList;
import java.util.List;
import java.util.ResourceBundle;

/**
 * Created by QiHan on 2016/8/16.
 */
public class userManagerUIController implements Initializable {

    @FXML
    private TableColumn<UserManageInfo, Boolean> selectColumn;
    @FXML
    private TableColumn<UserManageInfo, String> userNameColumn, userTypeColumn, nameColumn, genderColumn, passwordColumn;
    @FXML
    private TableView<UserManageInfo> table;
    @FXML
    private TextField userNameField, nameField, passwordField;
    @FXML
    private ChoiceBox userTypeChoBox, genderChoBox, choiceBox;
    @FXML
    private Label tipLabel;
    private int selectedIndex;
    private String userType, genderType;
    private String[] userTypes = {"normal", "manager"};
    private String[] genderTypes = {"male", "female"};
    private String[] choiceTypes = {"类型", "性别", "全部"};

    private BLInterfaces blInterfaces = new BLInterfaces();
    private UserLogic userLogic;
    private List<UserManageInfo> userManageInfoList = new ArrayList<UserManageInfo>();
    private UserManageInfo userManageInfo = new UserManageInfo();
    private UserManageInfo updateUserManageInfo = new UserManageInfo();
    private userManagerUIController instance;
    private boolean isUpdate;

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        instance = this;
        userLogic = blInterfaces.getUserLogic();
        initButton();
        init();
    }

    private void init() {
        tipLabel.setText(null);

        try {
            userManageInfoList = userLogic.getAllUser();
        } catch (RemoteException e) {
            e.printStackTrace();
        }
        table.setItems(FXCollections.observableArrayList(userManageInfoList));
        table.setRowFactory(new Callback<TableView<UserManageInfo>, TableRow<UserManageInfo>>() {
            @Override
            public TableRow<UserManageInfo> call(TableView<UserManageInfo> table) {
                // TODO Auto-generated method stub

                return new TableRowControl(table);
            }
        });
        selectColumn.setCellValueFactory(new PropertyValueFactory<UserManageInfo, Boolean>("select"));
        selectColumn.setCellFactory(new Callback<TableColumn<UserManageInfo, Boolean>, TableCell<UserManageInfo, Boolean>>() {
            @Override
            public TableCell<UserManageInfo, Boolean> call(
                    TableColumn<UserManageInfo, Boolean> param) {
                CheckBoxTableCell<UserManageInfo, Boolean> cell = new CheckBoxTableCell<>();
                cell.setAlignment(Pos.CENTER);
                return cell;
            }
        });


        userTypeColumn.setCellValueFactory(cellData -> new SimpleStringProperty(
                cellData.getValue().userType.toString()));
        userNameColumn.setCellValueFactory(cellData -> new SimpleStringProperty(
                cellData.getValue().username));
        nameColumn.setCellValueFactory(cellData -> new SimpleStringProperty(
                cellData.getValue().name));
        genderColumn.setCellValueFactory(cellData -> new SimpleStringProperty(
                cellData.getValue().gender));
        passwordColumn.setCellValueFactory(cellData -> new SimpleStringProperty(
                cellData.getValue().password));


        userTypeChoBox.setValue("normal");
        genderChoBox.setValue("male");
        choiceBox.setValue("全部");
        userTypeChoBox.setItems(FXCollections.observableArrayList(userTypes));
        genderChoBox.setItems(FXCollections.observableArrayList(genderTypes));
        choiceBox.setItems(FXCollections.observableArrayList(choiceTypes));

    }

    public void initButton() {

        genderChoBox.getSelectionModel().selectedIndexProperty().addListener((ov, oldv, newv) -> {
            if (newv.intValue() == 0 || newv.intValue() == 1)
                genderType = genderTypes[newv.intValue()];
            System.out.println("the selected is?: " + genderType);
        });

        userTypeChoBox.getSelectionModel().selectedIndexProperty().addListener((ov, oldv, newv) -> {
            if (newv.intValue() == 0 || newv.intValue() == 1)
                userType = userTypes[newv.intValue()];
            System.out.println("the selected userType is?: " + userType);
        });

    }

    @FXML
    private void ensureDelete() {
        try {
            userLogic.deleteUser(updateUserManageInfo);
        } catch (RemoteException e) {
            e.printStackTrace();
        } catch (ObjectNotFoundException e) {
            e.printStackTrace();
        }
        init();
    }


    @FXML
    private void addNewUser() {
        userManageInfo.name = nameField.getText();
        userManageInfo.username = userNameField.getText();
        userManageInfo.password = passwordField.getText();
        userManageInfo.gender = genderType;

        if (userType.equalsIgnoreCase("manager"))
            userManageInfo.userType = UserType.MANAGER;
        else if (userType.equalsIgnoreCase("normal"))
            userManageInfo.userType = UserType.NORMAL;

        try {
            if (!isUpdate) {
                userLogic.addUser(userManageInfo);
            } else {
                userLogic.updateUserInfo(userManageInfo);
            }
            init();
            MainUI.getInstance().displaySuccessPane();
            isUpdate = false;
            userNameField.setEditable(true);
        } catch (RemoteException e) {
            e.printStackTrace();
            tipLabel.setText("RemoteException！");
        } catch (ObjectExistedException e) {
            e.printStackTrace();
            //     tipLabel.setText("该用户已存在！");
            MainUI.getInstance().addInfoPanel("该用户已存在！");
        } catch (ObjectNotFoundException e) {
            e.printStackTrace();
        }

    }

    @FXML
    private void deleteAllSelected() {
        try {
            userLogic.deleteUser(updateUserManageInfo);
            init();
        } catch (RemoteException e) {
            e.printStackTrace();
        } catch (ObjectNotFoundException e) {
            e.printStackTrace();
        }
    }

    @FXML
    private void showAddList() {
        userNameField.clear();
        nameField.clear();
        passwordField.clear();
    }

    @FXML
    private void updateAllUser() {
        init();
    }


    public class TableRowControl<T> extends TableRow<T> {

        public TableRowControl(TableView<T> tableView) {
            super();
            this.setOnMouseClicked(new EventHandler<MouseEvent>() {
                @Override
                public void handle(MouseEvent event) {
                    if (event.getButton().equals(MouseButton.PRIMARY)
                            && event.getClickCount() == 2
                            && TableRowControl.this.getIndex() < table.getItems().size()) {
                        selectedIndex = userManagerUIController.TableRowControl.this.getIndex();
                        updateData();
                        nameField.setText(updateUserManageInfo.name);
                        userNameField.setText(updateUserManageInfo.username);
                        passwordField.setText(updateUserManageInfo.password);
                        userTypeChoBox.setValue(updateUserManageInfo.userType);
                        genderChoBox.setValue(updateUserManageInfo.gender);
                        isUpdate = true;
                        userNameField.setEditable(false);
                    }
                    if (event.getButton().equals(MouseButton.PRIMARY)
                            && event.getClickCount() == 1
                            && TableRowControl.this.getIndex() < table.getItems().size()) {

                        selectedIndex = userManagerUIController.TableRowControl.this.getIndex();
                        updateData();
                    }
                }
            });
        }
    }

    private void updateData() {
        updateUserManageInfo.name = nameColumn.getCellData(selectedIndex);
        updateUserManageInfo.password = passwordColumn.getCellData(selectedIndex);
        updateUserManageInfo.username = userNameColumn.getCellData(selectedIndex);
        updateUserManageInfo.gender = genderColumn.getCellData(selectedIndex);

        if (userTypeColumn.getCellData(selectedIndex).equals("MANAGER")) {
            updateUserManageInfo.userType = UserType.MANAGER;
        } else if (userTypeColumn.getCellData(selectedIndex).equals("NORMAL")) {
            updateUserManageInfo.userType = UserType.NORMAL;
        } else {
            System.out.println("......get user type fail......");
        }
    }
}
