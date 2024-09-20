## WPF

이전에 넷게임즈에서 ai tool 만들면서 적어둔 메모들. 의미 없는 메모들은 차후에 정리가 필요하다. 

 * 현재 실행경로 : Directory.GetCurrentDirectory()
 * 실행파일 존재 경로 : AppDomain.CurrentDomain.BaseDirectory
  * 혹은 string appStartPath = System.IO.Path.GetDirectoryName(Process.GetCurrentProcess().MainModule.FileName);
  * WPF가 아닌 C#에서는 Application.StartupPath

## WPF Canvas

### 클릭 이벤트가 안되는 컨트롤(ex:border)에 이벤트 처리 연결하기 - using ContentControl
참조 : http://blogs.microsoft.co.il/pavely/2011/08/03/wpf-tip-using-a-mousedoubleclick-event-where-none-exists/

## AvalonDock

### AvalonDock.PropertyGrid 에서 입력부분 사용자 정의 방법

1. in xaml
```
<xctk:PropertyGrid NameColumnWidth="110" x:Name="_propertyGrid" IsCategorized="True">
    <xctk:PropertyGrid.EditorDefinitions>
        <xctk:EditorTemplateDefinition TargetProperties="Candidates2">
            <xctk:EditorTemplateDefinition.EditingTemplate>
                <DataTemplate>
                    <TextBlock Text="Hello world" />
                </DataTemplate>
            </xctk:EditorTemplateDefinition.EditingTemplate>
        </xctk:EditorTemplateDefinition>
    </xctk:PropertyGrid.EditorDefinitions>
</xctk:PropertyGrid>
```

2. in codebehind
참고 : http://www.gamedevforever.com/217 - AvalonDock은 아닌데, XamlReader를 쓰는 예제를 볼 수 있다.
```
var definition = new EditorTemplateDefinition();
definition.TargetProperties.Add("Candidates3");
string xaml = @"<DataTemplate xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'>
    <TextBlock Text='Hello world2' />
</DataTemplate>";

using (var stream = new MemoryStream(Encoding.UTF8.GetBytes(xaml)))
{
    definition.EditingTemplate = XamlReader.Load(stream) as DataTemplate;
}

_propertyGrid.EditorDefinitions.Add(definition);
```

3. Implement ITypeEditor
```
class EnumSetEditor<T> : ITypeEditor
{
    private HashSet<T> data;

    public FrameworkElement ResolveEditor(PropertyItem propertyItem)
    {
        data = propertyItem.Instance.GetType().GetProperty(propertyItem.PropertyName)
            .GetValue(propertyItem.Instance) as HashSet<T>;

        var panel = new StackPanel();
        panel.Margin = new Thickness(10);

        foreach (string name in Enum.GetNames(typeof(T)))
        {
            T enumValue = (T)Enum.Parse(typeof(T), name);

            var checkBox = new CheckBox();
            checkBox.Content = new TextBlock { Text = name };
            checkBox.Checked += CheckBox_Checked;
            checkBox.Tag = enumValue;
            checkBox.IsChecked = data.Contains(enumValue);

            panel.Children.Add(checkBox);
        }

        return panel;
    }

    private void CheckBox_Checked(object sender, RoutedEventArgs e)
    {
        CheckBox checkBox = sender as CheckBox;
        T enumValue = (T)checkBox.Tag;
        if (checkBox.IsChecked.HasValue && checkBox.IsChecked.Value)
        {
            data.Add(enumValue);
        }
        else
        {
            data.Remove(enumValue);
        }
    }
}
```


### Binding a Contextmenu to an MVVM Command
reference : https://stackoverflow.com/questions/3583507/wpf-binding-a-contextmenu-to-an-mvvm-command
```
<StackPanel Orientation="Horizontal" Name="TargetStackPanel" Tag="{Binding Path=DataContext,
    RelativeSource={RelativeSource Mode=FindAncestor,
    AncestorLevel=2, AncestorType={x:Type Grid}}}">
    <StackPanel.ContextMenu>
        <ContextMenu DataContext="{Binding Path=PlacementTarget.Tag, RelativeSource={RelativeSource Mode=Self}}">
            <MenuItem Header="Add New MapEvent" Command="{Binding Path=NewMapEvent}" />
        </ContextMenu>
    </StackPanel.ContextMenu>
    <TextBlock Text="{Binding DisplayName}" Tag="{Binding .}" />
</StackPanel>

```

### canvas에 binding 형태로 객체 그리기
힌트만. 출처 : https://stackoverflow.com/questions/7177432/how-to-display-items-in-canvas-through-binding
```
<ItemsControl ItemsSource="{Binding Path=ItemsToShowInCanvas}">
    <ItemsControl.ItemsPanel>
        <ItemsPanelTemplate>
            <Canvas/>
        </ItemsPanelTemplate>
    </ItemsControl.ItemsPanel>
    <ItemsControl.ItemContainerStyle>
        <Style TargetType="ContentPresenter">
            <Setter Property="Canvas.Left" Value="{Binding Left}"/>
            <Setter Property="Canvas.Top" Value="{Binding Top}"/>
        </Style>
    </ItemsControl.ItemContainerStyle>
    <ItemsControl.ItemTemplate>
        <DataTemplate>
            <TextBlock Text="{Binding Path=Text}" />
        </DataTemplate>
    </ItemsControl.ItemTemplate>
</ItemsControl>
```