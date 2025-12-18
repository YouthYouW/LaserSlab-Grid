import csv
import sys

# 定义输入和输出文件名
INPUT_FILENAME = 'refinement_regions.csv'
OUTPUT_FILENAME = 'flash_params_generated.txt'

def clean_header(header):
    """去除表头中的BOM和空格"""
    return header.strip().replace('\ufeff', '')

def calculate_params(row, line_num):
    """从一行CSV数据中计算中心点和尺寸"""
    try:
        # 使用 strip() 去除可能存在的空格
        region_id = row['region'].strip()
        
        # 注意：这里对应您的英文表头
        x_left = float(row['x_left'])
        x_right = float(row['x_right'])
        y_low = float(row['y_low'])
        y_high = float(row['y_high'])
        level = int(row['refine_level'])

        center_x = (x_left + x_right) / 2
        center_y = (y_low + y_high) / 2
        size_x = (x_right - x_left) / 2
        size_y = (y_high - y_low) / 2
        
        return {
            'table_region': region_id,
            'level': level,
            'center_x': center_x,
            'center_y': center_y,
            'size_x': size_x,
            'size_y': size_y
        }
    except ValueError as e:
        print(f"❌ 数据格式错误 (第 {line_num} 行): {e}")
        print(f"   原始内容: {row}")
        print("   提示: 请检查是否有中文逗号，或者类似 '0,000' 这样错误的数字格式。\n")
        sys.exit(1)

def generate_flash_par():
    print(f"正在读取文件: {INPUT_FILENAME} ...")
    
    regions = []
    
    try:
        # 使用 utf-8-sig 编码来自动处理 Excel 保存时可能产生的 BOM 头
        with open(INPUT_FILENAME, mode='r', encoding='utf-8-sig') as infile:
            # 读取第一行来检查表头
            reader = csv.DictReader(infile, skipinitialspace=True)
            
            # 获取表头并去除空格，用于调试
            headers = [h.strip() for h in reader.fieldnames] if reader.fieldnames else []
            
            # 检查是否包含必要的列
            required_col = 'region'
            if required_col not in headers:
                print(f"\n❌ 错误：找不到列头 '{required_col}'")
                print(f"ℹ️  程序实际读取到的列头是: {headers}")
                print("   原因可能是：文件编码问题、表头拼写错误或包含隐藏字符。")
                return

            # 逐行处理数据
            for i, row in enumerate(reader, start=2): # 从第2行开始（第1行是表头）
                # 清理 row 的 key，防止 key 里面有空格
                clean_row = {k.strip(): v for k, v in row.items() if k}
                if not clean_row: continue # 跳过空行
                regions.append(calculate_params(clean_row, i))
                
    except FileNotFoundError:
        print(f"\n❌ 错误：找不到文件 '{INPUT_FILENAME}'")
        return
    except Exception as e:
        print(f"\n❌ 发生未知错误: {e}")
        return

    if not regions:
        print("⚠️  警告：没有读取到有效数据。")
        return

    max_refine_level = max(region['level'] for region in regions)
    
    # 写入文件
    with open(OUTPUT_FILENAME, 'w', encoding='utf-8') as outfile:
        def write_and_print(text=""):
            # print(text) # 如果不想在屏幕刷屏，可以注释掉这一行
            outfile.write(text + "\n")

        write_and_print("# --- CORE AMR and HOOK PARAMETERS ---")
        write_and_print("sim_useRefineSpecialized     = .true.")
        write_and_print("sim_useGeometryRefinement    = .true.")
        write_and_print(f"sim_geom_refine_nregions     = {len(regions)}")
        write_and_print()
        
        write_and_print("# ==========================================================================")
        write_and_print("# === REGIONS GENERATED FROM CSV ===")
        write_and_print("# ==========================================================================")
        write_and_print()

        for i, region in enumerate(regions, start=1):
            # 这里 i 是生成的序列号 (1, 2...), region['table_region'] 是CSV里写的编号
            write_and_print(f"# --- Region {i} (CSV ID: {region['table_region']}): (Level {region['level']}) ---")
            write_and_print(f"sim_geom_refine_shape_{i:<7} = \"box\"")
            write_and_print(f"sim_geom_refine_level_{i:<7} = {region['level']}")
            write_and_print(f"sim_geom_refine_center_x_{i:<3} = {region['center_x']:.6g}")
            write_and_print(f"sim_geom_refine_center_y_{i:<3} = {region['center_y']:.6g}")
            write_and_print(f"sim_geom_refine_size_x_{i:<5} = {region['size_x']:.6g}")
            write_and_print(f"sim_geom_refine_size_y_{i:<5} = {region['size_y']:.6g}")
            write_and_print()
        
        write_and_print("# 确保最大加密等级设置正确")
        write_and_print(f"lrefine_max                  = {max_refine_level}")
    
    print("-" * 50)
    print(f"✅ 成功！已生成 {len(regions)} 个区域。")
    print(f"📄 结果已写入: {OUTPUT_FILENAME}")
    print("-" * 50)

if __name__ == "__main__":
    generate_flash_par()